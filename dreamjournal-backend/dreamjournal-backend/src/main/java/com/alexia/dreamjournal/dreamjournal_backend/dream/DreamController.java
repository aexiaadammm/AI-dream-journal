package com.alexia.dreamjournal.dreamjournal_backend.dream;

import com.alexia.dreamjournal.dreamjournal_backend.ai.AIService;
import com.alexia.dreamjournal.dreamjournal_backend.ai.DreamAnalysisRequest;
import com.alexia.dreamjournal.dreamjournal_backend.ai.DreamAnalysisResult;
import com.alexia.dreamjournal.dreamjournal_backend.ai.FallbackAIService;
import com.alexia.dreamjournal.dreamjournal_backend.ai.OpenAIProperties;
import java.util.List;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/dreams")
public class DreamController {

    private final DreamService dreamService;
    private final AIService aiService;
    private final FallbackAIService fallbackAIService;
    private final OpenAIProperties openAIProperties;

    public DreamController(
            DreamService dreamService,
            AIService aiService,
            FallbackAIService fallbackAIService,
            OpenAIProperties openAIProperties
    ) {
        this.dreamService = dreamService;
        this.aiService = aiService;
        this.fallbackAIService = fallbackAIService;
        this.openAIProperties = openAIProperties;
    }

    @GetMapping
    public ResponseEntity<List<DreamEntry>> getDreams() {
        return ResponseEntity.ok(dreamService.findAll());
    }

    @PostMapping
    public ResponseEntity<DreamEntry> createDream(@RequestBody CreateDreamRequest request) {
        return ResponseEntity.ok(dreamService.createDream(request));
    }

    @GetMapping("/{id}")
    public ResponseEntity<DreamEntry> getDream(@PathVariable Long id) {
        return ResponseEntity.ok(dreamService.findById(id));
    }

    @PostMapping("/{id}/analyze")
    public ResponseEntity<DreamAnalysisResult> analyzeDream(
            @PathVariable Long id,
            @RequestBody DreamAnalysisRequest request
    ) {
        if (!openAIProperties.useOpenAI()) {
            DreamAnalysisResult result = fallbackAIService.analyzeDream(request, "AI_PROVIDER=fallback");
            dreamService.analyzeExistingDream(id, request, result, null);
            return ResponseEntity.ok(result);
        }

        var embedding = dreamService.createEmbedding(request);
        var similarDreams = dreamService.findSimilarDreams(request.userId(), id, embedding);
        DreamAnalysisResult result = aiService.analyzeDream(request, similarDreams);

        if (!dreamService.hasEnoughPatternEvidence(similarDreams)) {
            result = new DreamAnalysisResult(
                    result.emotionalTone(),
                    result.themes(),
                    result.symbols(),
                    result.possibleMeanings(),
                    result.reflectionQuestions(),
                    result.tags(),
                    "No strong repeated pattern yet. More dreams will make the pattern view more meaningful."
            );
        }

        dreamService.analyzeExistingDream(id, request, result, dreamService.embeddingToJson(embedding));
        return ResponseEntity.ok(result);
    }
}
