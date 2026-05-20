package com.alexia.dreamjournal.dreamjournal_backend.ai;

import com.alexia.dreamjournal.dreamjournal_backend.dream.DreamService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/ai")
public class AIController {

    private final AIService aiService;
    private final FallbackAIService fallbackAIService;
    private final OpenAIProperties openAIProperties;
    private final DreamService dreamService;

    public AIController(
            AIService aiService,
            FallbackAIService fallbackAIService,
            OpenAIProperties openAIProperties,
            DreamService dreamService
    ) {
        this.aiService = aiService;
        this.fallbackAIService = fallbackAIService;
        this.openAIProperties = openAIProperties;
        this.dreamService = dreamService;
    }

    @PostMapping("/analyze")
    public ResponseEntity<DreamAnalysisResponse> analyzeDream(@RequestBody DreamAnalysisRequest request) {
        if (!openAIProperties.useOpenAI()) {
            DreamAnalysisResult result = fallbackAIService.analyzeDream(request, "AI_PROVIDER=fallback");
            DreamAnalysisResponse response = aiService.toLegacyResponse(result);
            saveOrUpdate(request, response, result, null);
            return ResponseEntity.ok(response);
        }

        DreamAnalysisResult result;
        String embeddingJson = null;
        try {
            var embedding = dreamService.createEmbedding(request);
            embeddingJson = dreamService.embeddingToJson(embedding);
            var similarDreams = dreamService.findSimilarDreams(request.userId(), null, embedding);
            result = aiService.analyzeDream(request, similarDreams);
            if (!dreamService.hasEnoughPatternEvidence(similarDreams)) {
                result = withNoPatternYet(result);
            }
        } catch (OpenAIException exception) {
            result = fallbackAIService.analyzeDream(request, exception.getMessage());
        }

        DreamAnalysisResponse response = aiService.toLegacyResponse(result);
        saveOrUpdate(request, response, result, embeddingJson);
        return ResponseEntity.ok(response);
    }

    private void saveOrUpdate(
            DreamAnalysisRequest request,
            DreamAnalysisResponse response,
            DreamAnalysisResult result,
            String embeddingJson
    ) {
        if (request.dreamId() == null) {
            dreamService.saveAnalyzedDream(request, response, embeddingJson);
            return;
        }

        dreamService.analyzeExistingDream(request.dreamId(), request, result, embeddingJson);
    }

    private DreamAnalysisResult withNoPatternYet(DreamAnalysisResult result) {
        return new DreamAnalysisResult(
                result.emotionalTone(),
                result.themes(),
                result.symbols(),
                result.possibleMeanings(),
                result.reflectionQuestions(),
                result.tags(),
                "No strong repeated pattern yet. More dreams will make the pattern view more meaningful."
        );
    }
}
