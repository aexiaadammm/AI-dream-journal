package com.alexia.dreamjournal.dreamjournal_backend.assistant;

import com.alexia.dreamjournal.dreamjournal_backend.ai.AIService;
import com.alexia.dreamjournal.dreamjournal_backend.ai.AssistantChatRequest;
import com.alexia.dreamjournal.dreamjournal_backend.ai.AssistantChatResponse;
import com.alexia.dreamjournal.dreamjournal_backend.ai.FallbackAIService;
import com.alexia.dreamjournal.dreamjournal_backend.ai.OpenAIException;
import com.alexia.dreamjournal.dreamjournal_backend.ai.OpenAIProperties;
import com.alexia.dreamjournal.dreamjournal_backend.dream.DreamService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/assistant")
public class AssistantController {

    private final AIService aiService;
    private final FallbackAIService fallbackAIService;
    private final OpenAIProperties openAIProperties;
    private final DreamService dreamService;

    public AssistantController(
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

    @PostMapping("/chat")
    public ResponseEntity<AssistantChatResponse> chat(@RequestBody AssistantChatRequest request) {
        if (!openAIProperties.useOpenAI()) {
            return ResponseEntity.ok(fallbackAIService.chat(request, "AI_PROVIDER=fallback"));
        }

        var relevantDreams = dreamService.findRelevantDreams(request.userId(), request.dreamId());
        try {
            return ResponseEntity.ok(aiService.chat(request, relevantDreams));
        } catch (OpenAIException exception) {
            return ResponseEntity.ok(fallbackAIService.chat(request, exception.getMessage()));
        }
    }
}
