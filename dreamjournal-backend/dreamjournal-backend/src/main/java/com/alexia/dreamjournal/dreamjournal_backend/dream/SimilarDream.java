package com.alexia.dreamjournal.dreamjournal_backend.dream;

public record SimilarDream(
        DreamEntry dream,
        double similarity
) {
}
