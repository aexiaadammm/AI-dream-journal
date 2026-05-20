package com.alexia.dreamjournal.dreamjournal_backend.ai;

import java.util.List;

public record DreamAnalysisResponse(
        String emotionalTone,
        List<String> possibleSymbols,
        String contextualInterpretation,
        List<String> reflectionQuestions,
        String dailyAdvice,
        List<String> dreamTypeFindings,
        String disclaimer,
        List<String> themes,
        List<String> possibleMeanings,
        List<String> tags,
        String patternObservation
) {
}
