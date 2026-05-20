package com.alexia.dreamjournal.dreamjournal_backend.ai;

import java.util.List;
import org.springframework.stereotype.Service;
import tools.jackson.core.JacksonException;
import tools.jackson.databind.ObjectMapper;

@Service
public class EmbeddingService {

    private final OpenAIClient openAIClient;
    private final ObjectMapper objectMapper;

    public EmbeddingService(OpenAIClient openAIClient, ObjectMapper objectMapper) {
        this.openAIClient = openAIClient;
        this.objectMapper = objectMapper;
    }

    public List<Double> createDreamEmbedding(DreamAnalysisRequest request) {
        return openAIClient.createEmbedding(buildEmbeddingText(request));
    }

    public String toJson(List<Double> embedding) {
        try {
            return objectMapper.writeValueAsString(embedding);
        } catch (JacksonException exception) {
            throw new OpenAIException("Could not serialize dream embedding.", exception);
        }
    }

    public List<Double> fromJson(String embeddingJson) {
        try {
            return objectMapper.readerForListOf(Double.class).readValue(embeddingJson);
        } catch (JacksonException exception) {
            throw new OpenAIException("Could not deserialize dream embedding.", exception);
        }
    }

    public double cosineSimilarity(List<Double> first, List<Double> second) {
        if (first.isEmpty() || second.isEmpty() || first.size() != second.size()) {
            return 0;
        }

        double dotProduct = 0;
        double firstMagnitude = 0;
        double secondMagnitude = 0;
        for (int index = 0; index < first.size(); index++) {
            double firstValue = first.get(index);
            double secondValue = second.get(index);
            dotProduct += firstValue * secondValue;
            firstMagnitude += firstValue * firstValue;
            secondMagnitude += secondValue * secondValue;
        }

        if (firstMagnitude == 0 || secondMagnitude == 0) {
            return 0;
        }

        return dotProduct / (Math.sqrt(firstMagnitude) * Math.sqrt(secondMagnitude));
    }

    private String buildEmbeddingText(DreamAnalysisRequest request) {
        return """
                Dream: %s
                Emotions: %s
                Sleep quality: %s
                Stress level: %s
                People: %s
                Places: %s
                Symbols: %s
                Recent life events: %s
                """.formatted(
                value(request.dreamText()),
                value(request.emotions()),
                value(request.sleepQuality()),
                request.stressLevel() == null ? "unknown" : request.stressLevel(),
                value(request.people()),
                value(request.places()),
                value(request.symbols()),
                value(request.recentLifeEvents())
        );
    }

    private String value(String text) {
        return text == null || text.isBlank() ? "not provided" : text;
    }
}
