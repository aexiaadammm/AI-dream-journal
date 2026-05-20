package com.alexia.dreamjournal.dreamjournal_backend.dream;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DreamRepository extends JpaRepository<DreamEntry, Long> {
    List<DreamEntry> findByUserIdOrderByCreatedAtDesc(String userId);
}
