package com.alexia.dreamjournal.dreamjournal_backend.dream;

import com.alexia.dreamjournal.dreamjournal_backend.ai.EmbeddingService;
import java.util.Comparator;
import java.util.List;
import org.springframework.stereotype.Service;

@Service
public class DreamPatternService {

    private static final double SIMILARITY_THRESHOLD = 0.82;

    private final EmbeddingService embeddingService;

    public DreamPatternService(EmbeddingService embeddingService) {
        this.embeddingService = embeddingService;
    }

    public List<SimilarDream> findSimilarDreams(List<Double> newEmbedding, List<DreamEntry> olderDreams) {
        return olderDreams.stream()
                .filter(dream -> dream.getEmbeddingJson() != null && !dream.getEmbeddingJson().isBlank())
                .map(dream -> new SimilarDream(
                        dream,
                        embeddingService.cosineSimilarity(
                                newEmbedding,
                                embeddingService.fromJson(dream.getEmbeddingJson())
                        )
                ))
                .filter(similarDream -> similarDream.similarity() >= SIMILARITY_THRESHOLD)
                .sorted(Comparator.comparingDouble(SimilarDream::similarity).reversed())
                .limit(5)
                .toList();
    }

    public boolean hasEnoughPatternEvidence(List<SimilarDream> similarDreams) {
        return similarDreams.size() >= 2;
    }
}
