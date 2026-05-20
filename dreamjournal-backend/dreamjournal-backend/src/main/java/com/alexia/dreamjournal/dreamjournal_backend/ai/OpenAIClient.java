package com.alexia.dreamjournal.dreamjournal_backend.ai;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import org.springframework.stereotype.Component;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

@Component
public class OpenAIClient {

    private final OpenAIProperties properties;
    private final ObjectMapper objectMapper;
    private final HttpClient httpClient;

    public OpenAIClient(OpenAIProperties properties, ObjectMapper objectMapper) {
        this.properties = properties;
        this.objectMapper = objectMapper;
        this.httpClient = HttpClient.newBuilder()
                .connectTimeout(Duration.ofSeconds(20))
                .build();
    }

    public String createResponse(String systemPrompt, String userPrompt, int maxOutputTokens) {
        ensureConfigured();

        Map<String, Object> body = Map.of(
                "model", properties.getModel(),
                "input", List.of(
                        Map.of("role", "system", "content", systemPrompt),
                        Map.of("role", "user", "content", userPrompt)
                ),
                "max_output_tokens", maxOutputTokens
        );

        JsonNode root = postJson(properties.getResponsesUrl(), body);
        String outputText = extractOutputText(root);
        if (outputText.isBlank()) {
            throw new OpenAIException("OpenAI response did not include text output.");
        }
        return outputText;
    }

    public List<Double> createEmbedding(String input) {
        ensureConfigured();

        Map<String, Object> body = Map.of(
                "model", properties.getEmbeddingModel(),
                "input", input
        );

        JsonNode root = postJson(properties.getEmbeddingsUrl(), body);
        JsonNode embeddingNode = root.path("data").path(0).path("embedding");
        if (!embeddingNode.isArray()) {
            throw new OpenAIException("OpenAI embedding response did not include an embedding vector.");
        }

        List<Double> embedding = new ArrayList<>();
        embeddingNode.forEach(value -> embedding.add(value.asDouble()));
        return embedding;
    }

    private JsonNode postJson(String url, Map<String, Object> body) {
        try {
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .timeout(Duration.ofSeconds(60))
                    .header("Authorization", "Bearer " + properties.getApiKey())
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(objectMapper.writeValueAsString(body)))
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() < 200 || response.statusCode() >= 300) {
                throw new OpenAIException("OpenAI request failed with status " + response.statusCode()
                        + ": " + response.body());
            }
            return objectMapper.readTree(response.body());
        } catch (IOException exception) {
            throw new OpenAIException("Could not call OpenAI API.", exception);
        } catch (InterruptedException exception) {
            Thread.currentThread().interrupt();
            throw new OpenAIException("OpenAI API call was interrupted.", exception);
        }
    }

    private String extractOutputText(JsonNode root) {
        JsonNode outputText = root.path("output_text");
        if (outputText.isTextual()) {
            return outputText.asText();
        }

        StringBuilder builder = new StringBuilder();
        for (JsonNode outputItem : root.path("output")) {
            for (JsonNode contentItem : outputItem.path("content")) {
                JsonNode text = contentItem.path("text");
                if (text.isTextual()) {
                    builder.append(text.asText());
                }
            }
        }
        return builder.toString();
    }

    private void ensureConfigured() {
        if (properties.getApiKey() == null || properties.getApiKey().isBlank()) {
            throw new OpenAIException("OPENAI_API_KEY is not configured on the backend.");
        }
    }
}
