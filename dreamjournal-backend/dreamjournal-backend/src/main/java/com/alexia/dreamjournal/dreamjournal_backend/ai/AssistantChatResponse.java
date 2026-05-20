package com.alexia.dreamjournal.dreamjournal_backend.ai;

import java.util.List;

public record AssistantChatResponse(
        String possibleInterpretation,
        List<String> emotionalThemes,
        List<String> reflectionQuestions,
        String patternObservation,
        String companionMessage,
        String disclaimer
) {
}
