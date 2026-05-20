package com.alexia.dreamjournal.dreamjournal_backend.dream;

public record CreateDreamRequest(
        String userId,
        String title,
        String dreamText,
        String mood
) {
}
