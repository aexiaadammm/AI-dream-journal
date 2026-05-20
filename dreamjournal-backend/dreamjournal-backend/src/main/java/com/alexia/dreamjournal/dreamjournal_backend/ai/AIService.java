package com.alexia.dreamjournal.dreamjournal_backend.ai;

import com.alexia.dreamjournal.dreamjournal_backend.dream.DreamEntry;
import com.alexia.dreamjournal.dreamjournal_backend.dream.SimilarDream;
import java.util.List;
import org.springframework.stereotype.Service;
import tools.jackson.core.JacksonException;
import tools.jackson.databind.ObjectMapper;

@Service
public class AIService {

    private final OpenAIClient openAIClient;
    private final ObjectMapper objectMapper;

    public AIService(OpenAIClient openAIClient, ObjectMapper objectMapper) {
        this.openAIClient = openAIClient;
        this.objectMapper = objectMapper;
    }

    public DreamAnalysisResult analyzeDream(DreamAnalysisRequest request, List<SimilarDream> similarDreams) {
        String systemPrompt = """
                You are a dream journal reflection companion.
                You are not a psychologist, therapist, doctor, or diagnostic tool.
                Offer gentle, culturally aware, non-medical interpretations.
                Avoid certainty. Use language like "could", "may", and "might".
                Return only valid JSON with these fields:
                emotionalTone: string,
                themes: string[],
                symbols: string[],
                possibleMeanings: string[],
                reflectionQuestions: string[],
                tags: string[],
                patternObservation: string.
                Keep arrays concise, with 3 to 6 items each.
                """;

        String userPrompt = """
                Analyze this dream for a personal dream journal.

                Current dream:
                %s

                User context:
                emotions=%s
                sleepQuality=%s
                stressLevel=%s
                people=%s
                places=%s
                symbols=%s
                culturalBackground=%s
                beliefs=%s
                profession=%s
                recentLifeEvents=%s

                Similar previous dreams, limited for cost:
                %s
                """.formatted(
                limit(request.dreamText(), 4000),
                value(request.emotions()),
                value(request.sleepQuality()),
                request.stressLevel() == null ? "unknown" : request.stressLevel(),
                value(request.people()),
                value(request.places()),
                value(request.symbols()),
                value(request.culturalBackground()),
                value(request.beliefs()),
                value(request.profession()),
                value(request.recentLifeEvents()),
                summarizeSimilarDreams(similarDreams)
        );

        String rawJson = openAIClient.createResponse(systemPrompt, userPrompt, 900);
        return parseJson(rawJson, DreamAnalysisResult.class);
    }

    public AssistantChatResponse chat(AssistantChatRequest request, List<DreamEntry> relevantDreams) {
        String systemPrompt = """
                You are a warm dream journal reflection companion.
                You are not a psychologist, therapist, doctor, or diagnostic tool.
                Do not diagnose mental health conditions and do not present dream meanings as facts.
                Answer in a reflective, conversational style.
                Return only valid JSON with these fields:
                possibleInterpretation: string,
                emotionalThemes: string[],
                reflectionQuestions: string[],
                patternObservation: string,
                companionMessage: string,
                disclaimer: string.
                """;

        String userPrompt = """
                User message:
                %s

                Current dream data:
                dreamId=%s
                dreamText=%s
                emotions=%s
                sleepQuality=%s
                stressLevel=%s
                people=%s
                places=%s
                symbols=%s
                culturalBackground=%s
                beliefs=%s
                profession=%s
                recentLifeEvents=%s

                Relevant previous dreams, maximum 5:
                %s
                """.formatted(
                limit(request.message(), 2000),
                request.dreamId() == null ? "none" : request.dreamId(),
                limit(request.dreamText(), 3500),
                value(request.emotions()),
                value(request.sleepQuality()),
                request.stressLevel() == null ? "unknown" : request.stressLevel(),
                value(request.people()),
                value(request.places()),
                value(request.symbols()),
                value(request.culturalBackground()),
                value(request.beliefs()),
                value(request.profession()),
                value(request.recentLifeEvents()),
                summarizeDreams(relevantDreams)
        );

        String rawJson = openAIClient.createResponse(systemPrompt, userPrompt, 900);
        return parseJson(rawJson, AssistantChatResponse.class);
    }

    public DreamAnalysisResponse toLegacyResponse(DreamAnalysisResult result) {
        String disclaimer = "This is a reflective interpretation, not a medical or psychological diagnosis.";
        return new DreamAnalysisResponse(
                result.emotionalTone(),
                result.symbols(),
                String.join(" ", result.possibleMeanings()),
                result.reflectionQuestions(),
                "Notice one small feeling or symbol from this dream today, without forcing a conclusion.",
                result.themes(),
                disclaimer,
                result.themes(),
                result.possibleMeanings(),
                result.tags(),
                result.patternObservation()
        );
    }

    private <T> T parseJson(String rawJson, Class<T> type) {
        try {
            String cleanedJson = rawJson
                    .replaceFirst("^```json\\s*", "")
                    .replaceFirst("^```\\s*", "")
                    .replaceFirst("\\s*```$", "")
                    .trim();
            return objectMapper.readValue(cleanedJson, type);
        } catch (JacksonException exception) {
            throw new OpenAIException("OpenAI returned invalid JSON: " + rawJson, exception);
        }
    }

    private String summarizeSimilarDreams(List<SimilarDream> similarDreams) {
        if (similarDreams.isEmpty()) {
            return "No similar previous dreams found.";
        }

        return similarDreams.stream()
                .limit(5)
                .map(similarDream -> "- similarity %.2f: %s".formatted(
                        similarDream.similarity(),
                        limit(similarDream.dream().getDreamText(), 600)
                ))
                .toList()
                .toString();
    }

    private String summarizeDreams(List<DreamEntry> dreams) {
        if (dreams.isEmpty()) {
            return "No previous dreams available.";
        }

        return dreams.stream()
                .limit(5)
                .map(dream -> "- %s | emotions=%s | themes=%s | text=%s".formatted(
                        dream.getCreatedAt(),
                        value(dream.getEmotions()),
                        dream.getThemes(),
                        limit(dream.getDreamText(), 600)
                ))
                .toList()
                .toString();
    }

    private String value(String text) {
        return text == null || text.isBlank() ? "not provided" : text;
    }

    private String limit(String text, int maxLength) {
        if (text == null) {
            return "not provided";
        }
        if (text.length() <= maxLength) {
            return text;
        }
        return text.substring(0, maxLength);
    }
}
