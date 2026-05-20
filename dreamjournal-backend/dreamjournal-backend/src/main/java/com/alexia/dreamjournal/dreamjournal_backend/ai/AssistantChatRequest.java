package com.alexia.dreamjournal.dreamjournal_backend.ai;

public record AssistantChatRequest(
        String userId,
        Long dreamId,
        String mode,
        String message,
        String dreamText,
        String emotions,
        String sleepQuality,
        Integer stressLevel,
        String people,
        String places,
        String symbols,
        String culturalBackground,
        String beliefs,
        String profession,
        String recentLifeEvents
) {
}
