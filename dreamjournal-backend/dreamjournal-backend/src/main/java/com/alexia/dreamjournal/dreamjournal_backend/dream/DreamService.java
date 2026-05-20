package com.alexia.dreamjournal.dreamjournal_backend.dream;

import com.alexia.dreamjournal.dreamjournal_backend.ai.DreamAnalysisRequest;
import com.alexia.dreamjournal.dreamjournal_backend.ai.DreamAnalysisResponse;
import com.alexia.dreamjournal.dreamjournal_backend.ai.DreamAnalysisResult;
import com.alexia.dreamjournal.dreamjournal_backend.ai.EmbeddingService;
import java.util.List;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

@Service
public class DreamService {

    private final DreamRepository dreamRepository;
    private final EmbeddingService embeddingService;
    private final DreamPatternService dreamPatternService;

    public DreamService(
            DreamRepository dreamRepository,
            EmbeddingService embeddingService,
            DreamPatternService dreamPatternService
    ) {
        this.dreamRepository = dreamRepository;
        this.embeddingService = embeddingService;
        this.dreamPatternService = dreamPatternService;
    }

    public DreamEntry saveAnalyzedDream(
            DreamAnalysisRequest request,
            DreamAnalysisResponse response,
            String embeddingJson
    ) {
        DreamEntry dreamEntry = new DreamEntry();
        dreamEntry.setUserId(resolveUserId(request.userId()));
        dreamEntry.setTitle(createTitle(request.dreamText()));
        dreamEntry.setDreamText(request.dreamText());
        dreamEntry.setEmotions(request.emotions());
        dreamEntry.setSleepQuality(request.sleepQuality());
        dreamEntry.setStressLevel(request.stressLevel());
        dreamEntry.setPeople(request.people());
        dreamEntry.setPlaces(request.places());
        dreamEntry.setSymbols(request.symbols());
        dreamEntry.setCulturalBackground(request.culturalBackground());
        dreamEntry.setBeliefs(request.beliefs());
        dreamEntry.setProfession(request.profession());
        dreamEntry.setRecentLifeEvents(request.recentLifeEvents());
        dreamEntry.setEmotionalTone(response.emotionalTone());
        dreamEntry.setPossibleSymbols(response.possibleSymbols());
        dreamEntry.setThemes(response.themes());
        dreamEntry.setPossibleMeanings(response.possibleMeanings());
        dreamEntry.setReflectionQuestions(response.reflectionQuestions());
        dreamEntry.setContextualInterpretation(response.contextualInterpretation());
        dreamEntry.setDailyAdvice(response.dailyAdvice());
        dreamEntry.setDreamTypeFindings(response.dreamTypeFindings());
        dreamEntry.setTags(response.tags());
        dreamEntry.setDisclaimer(response.disclaimer());
        dreamEntry.setPatternObservation(response.patternObservation());
        dreamEntry.setEmbeddingJson(embeddingJson);

        return dreamRepository.save(dreamEntry);
    }

    public DreamEntry createDream(CreateDreamRequest request) {
        DreamEntry dreamEntry = new DreamEntry();
        dreamEntry.setUserId(resolveUserId(request.userId()));
        dreamEntry.setTitle(request.title());
        dreamEntry.setDreamText(request.dreamText());
        dreamEntry.setEmotions(request.mood());
        return dreamRepository.save(dreamEntry);
    }

    public DreamEntry analyzeExistingDream(Long id, DreamAnalysisRequest request, DreamAnalysisResult result, String embeddingJson) {
        DreamEntry dreamEntry = findById(id);
        dreamEntry.setUserId(resolveUserId(request.userId()));
        dreamEntry.setDreamText(request.dreamText());
        dreamEntry.setEmotions(request.emotions());
        dreamEntry.setSleepQuality(request.sleepQuality());
        dreamEntry.setStressLevel(request.stressLevel());
        dreamEntry.setPeople(request.people());
        dreamEntry.setPlaces(request.places());
        dreamEntry.setSymbols(request.symbols());
        dreamEntry.setCulturalBackground(request.culturalBackground());
        dreamEntry.setBeliefs(request.beliefs());
        dreamEntry.setProfession(request.profession());
        dreamEntry.setRecentLifeEvents(request.recentLifeEvents());
        dreamEntry.setEmotionalTone(result.emotionalTone());
        dreamEntry.setPossibleSymbols(result.symbols());
        dreamEntry.setThemes(result.themes());
        dreamEntry.setPossibleMeanings(result.possibleMeanings());
        dreamEntry.setReflectionQuestions(result.reflectionQuestions());
        dreamEntry.setTags(result.tags());
        dreamEntry.setPatternObservation(result.patternObservation());
        dreamEntry.setEmbeddingJson(embeddingJson);

        return dreamRepository.save(dreamEntry);
    }

    public List<Double> createEmbedding(DreamAnalysisRequest request) {
        return embeddingService.createDreamEmbedding(request);
    }

    public String embeddingToJson(List<Double> embedding) {
        return embeddingService.toJson(embedding);
    }

    public List<SimilarDream> findSimilarDreams(String userId, Long currentDreamId, List<Double> embedding) {
        return dreamPatternService.findSimilarDreams(
                embedding,
                findByUserId(resolveUserId(userId)).stream()
                        .filter(dream -> currentDreamId == null || !currentDreamId.equals(dream.getId()))
                        .toList()
        );
    }

    public boolean hasEnoughPatternEvidence(List<SimilarDream> similarDreams) {
        return dreamPatternService.hasEnoughPatternEvidence(similarDreams);
    }

    public List<DreamEntry> findAll() {
        return dreamRepository.findAll(Sort.by(Sort.Direction.DESC, "createdAt"));
    }

    public List<DreamEntry> findByUserId(String userId) {
        return dreamRepository.findByUserIdOrderByCreatedAtDesc(resolveUserId(userId));
    }

    public List<DreamEntry> findRelevantDreams(String userId, Long dreamId) {
        return findByUserId(userId).stream()
                .filter(dream -> dreamId == null || !dreamId.equals(dream.getId()))
                .limit(5)
                .toList();
    }

    public DreamEntry findById(Long id) {
        return dreamRepository.findById(id)
                .orElseThrow(() -> new DreamNotFoundException(id));
    }

    public String resolveUserId(String userId) {
        return userId == null || userId.isBlank() ? "default-user" : userId;
    }

    private String createTitle(String dreamText) {
        if (dreamText == null || dreamText.isBlank()) {
            return "Untitled dream";
        }
        String title = dreamText.trim();
        if (title.length() <= 40) {
            return title;
        }
        return title.substring(0, 40) + "...";
    }
}
