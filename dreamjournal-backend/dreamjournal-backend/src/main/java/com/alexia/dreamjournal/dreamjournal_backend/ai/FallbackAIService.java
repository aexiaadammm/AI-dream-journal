package com.alexia.dreamjournal.dreamjournal_backend.ai;

import java.util.ArrayList;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class FallbackAIService {

    public DreamAnalysisResult analyzeDream(DreamAnalysisRequest request, String reason) {
        List<String> themes = inferThemes(request);
        List<String> symbols = splitList(request.symbols());
        if (symbols.isEmpty()) {
            symbols = inferSymbols(request.dreamText());
        }

        return new DreamAnalysisResult(
                inferTone(request),
                themes,
                symbols,
                associationMeanings(request, symbols),
                associationQuestions(request, symbols),
                themes.stream().map(theme -> theme.toLowerCase().replace(" ", "-")).toList(),
                "Reflection demo mode: " + reason
        );
    }

    public AssistantChatResponse chat(AssistantChatRequest request, String reason) {
        if ("creativeTransformation".equalsIgnoreCase(request.mode())) {
            return creativeTransformationChat(request, reason);
        }

        List<String> symbols = splitList(request.symbols());
        if (symbols.isEmpty()) {
            symbols = inferSymbols(request.dreamText());
        }

        return new AssistantChatResponse(
                "The dream can be explored as a possible indirect expression of emotional tension, wishes, fears, or unresolved daily material. This does not mean one fixed interpretation; it means we look at the dream's symbols and ask what personal associations they wake up in you.",
                inferThemes(new DreamAnalysisRequest(
                        request.userId(),
                        request.dreamId(),
                        request.dreamText(),
                        request.emotions(),
                        request.sleepQuality(),
                        request.stressLevel(),
                        request.people(),
                        request.places(),
                        request.symbols(),
                        request.culturalBackground(),
                        request.beliefs(),
                        request.profession(),
                        request.recentLifeEvents()
                )),
                associationQuestions(new DreamAnalysisRequest(
                        request.userId(),
                        request.dreamId(),
                        request.dreamText(),
                        request.emotions(),
                        request.sleepQuality(),
                        request.stressLevel(),
                        request.people(),
                        request.places(),
                        request.symbols(),
                        request.culturalBackground(),
                        request.beliefs(),
                        request.profession(),
                        request.recentLifeEvents()
                ), symbols),
                "Reflection demo mode: " + reason,
                "I would start with your own associations: what each symbol reminds you of, what feeling it hides or exaggerates, and whether the dream changes something uncomfortable into an image that feels safer to look at.",
                "This is reflective support, not a medical or psychological diagnosis."
        );
    }

    private AssistantChatResponse creativeTransformationChat(AssistantChatRequest request, String reason) {
        String interest = request.profession() == null || request.profession().isBlank()
                ? "your current interest"
                : request.profession();
        List<String> symbols = splitList(request.symbols());
        if (symbols.isEmpty()) {
            symbols = inferSymbols(request.dreamText());
        }
        String symbol = symbols.isEmpty() ? "the strongest dream image" : symbols.get(0);

        return new AssistantChatResponse(
                "For creative transformation, treat the dream as raw material rather than a prediction. The image \"" + symbol + "\" can become a practical exercise connected to " + interest + ".",
                List.of("creative translation", "personal association", "symbol into action"),
                List.of(
                        "What does \"" + symbol + "\" remind you of in " + interest + "?",
                        "Could this symbol become a lesson, sketch, checklist, scene, design, routine, or small experiment?",
                        "What part of the dream is still unclear, and what extra detail would help connect it to your interest?"
                ),
                "Reflection demo mode: " + reason,
                "A concrete step: write the symbol in the center of a page, add three associations around it, then turn one association into a small task for " + interest + ". If the connection feels weak, answer the questions first instead of forcing the interpretation.",
                "This is creative reflection, not diagnosis or professional mental health advice."
        );
    }

    private String inferTone(DreamAnalysisRequest request) {
        String emotions = request.emotions() == null ? "" : request.emotions().toLowerCase();
        if (emotions.contains("fear") || emotions.contains("sad") || emotions.contains("stress")) {
            return "tense and emotionally charged";
        }
        if (emotions.contains("joy") || emotions.contains("relief") || emotions.contains("calm")) {
            return "soft and reflective";
        }
        return "mixed and reflective";
    }

    private List<String> inferThemes(DreamAnalysisRequest request) {
        List<String> themes = new ArrayList<>();
        String text = ((request.dreamText() == null ? "" : request.dreamText()) + " "
                + (request.recentLifeEvents() == null ? "" : request.recentLifeEvents())).toLowerCase();

        if (text.contains("death") || text.contains("died")) {
            themes.add("change or ending");
        }
        if (text.contains("water") || text.contains("sea") || text.contains("rain")) {
            themes.add("emotional processing");
        }
        if (text.contains("school") || text.contains("university") || text.contains("exam")) {
            themes.add("pressure and performance");
        }
        if (themes.isEmpty()) {
            themes.add("personal reflection");
            themes.add("emotional context");
        }
        return themes;
    }

    private List<String> associationMeanings(DreamAnalysisRequest request, List<String> symbols) {
        List<String> meanings = new ArrayList<>();
        meanings.add("A useful method is free association: what each image personally reminds you of, rather than a universal dictionary meaning.");
        meanings.add("The dream may contain a visible story and a more hidden emotional layer behind it.");
        meanings.add("Repeated or intense symbols may point to wishes, conflicts, anxieties, or recent experiences transformed into safer dream images.");
        if (request.stressLevel() != null && request.stressLevel() >= 7) {
            meanings.add("Because your stress level is high, the dream may be carrying daily pressure into symbolic form.");
        }
        if (!symbols.isEmpty()) {
            meanings.add("Start with the symbol \"" + symbols.get(0) + "\" and list memories, people, fears, desires, or places it brings to mind.");
        }
        return meanings;
    }

    private List<String> associationQuestions(DreamAnalysisRequest request, List<String> symbols) {
        List<String> questions = new ArrayList<>();
        questions.add("What is your first personal association with the strongest dream image?");
        questions.add("What feeling might the dream be disguising, softening, or exaggerating?");
        questions.add("What recent event could be the day residue that fed the dream?");
        questions.add("If the dream contained a wish or fear, what would it be trying to say indirectly?");
        if (!symbols.isEmpty()) {
            questions.add("When you think of \"" + symbols.get(0) + "\", what memory or person appears first?");
        }
        return questions;
    }

    private List<String> inferSymbols(String dreamText) {
        String text = dreamText == null ? "" : dreamText.toLowerCase();
        List<String> symbols = new ArrayList<>();
        if (text.contains("death") || text.contains("died")) {
            symbols.add("death as symbolic ending");
        }
        if (text.contains("water")) {
            symbols.add("water");
        }
        if (text.contains("bridge")) {
            symbols.add("bridge");
        }
        if (symbols.isEmpty()) {
            symbols.add("strongest remembered image");
        }
        return symbols;
    }

    private List<String> splitList(String text) {
        if (text == null || text.isBlank()) {
            return List.of();
        }
        return List.of(text.split(",")).stream()
                .map(String::trim)
                .filter(value -> !value.isBlank())
                .toList();
    }
}
