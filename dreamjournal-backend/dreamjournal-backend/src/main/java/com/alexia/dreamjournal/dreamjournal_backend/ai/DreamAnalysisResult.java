package com.alexia.dreamjournal.dreamjournal_backend.ai;

import java.util.List;

public record DreamAnalysisResult(
        String emotionalTone,
        List<String> themes,
        List<String> symbols,
        List<String> possibleMeanings,
        List<String> reflectionQuestions,
        List<String> tags,
        String patternObservation
) {
}
