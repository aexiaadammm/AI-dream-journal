package com.alexia.dreamjournal.dreamjournal_backend.dream;

import jakarta.persistence.Column;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OrderColumn;
import jakarta.persistence.PrePersist;
import jakarta.persistence.Table;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "dream_entries")
public class DreamEntry {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;

    private String userId = "default-user";

    @Column(nullable = false, columnDefinition = "text")
    private String dreamText;

    @Column(columnDefinition = "text")
    private String emotions;

    private String sleepQuality;

    private Integer stressLevel;

    @Column(columnDefinition = "text")
    private String people;

    @Column(columnDefinition = "text")
    private String places;

    @Column(columnDefinition = "text")
    private String symbols;

    @Column(columnDefinition = "text")
    private String culturalBackground;

    @Column(columnDefinition = "text")
    private String beliefs;

    private String profession;

    @Column(columnDefinition = "text")
    private String recentLifeEvents;

    private String emotionalTone;

    @ElementCollection(fetch = FetchType.EAGER)
    @OrderColumn(name = "symbol_order")
    private List<String> possibleSymbols = new ArrayList<>();

    @ElementCollection(fetch = FetchType.EAGER)
    @OrderColumn(name = "theme_order")
    private List<String> themes = new ArrayList<>();

    @ElementCollection(fetch = FetchType.EAGER)
    @OrderColumn(name = "meaning_order")
    private List<String> possibleMeanings = new ArrayList<>();

    @ElementCollection(fetch = FetchType.EAGER)
    @OrderColumn(name = "question_order")
    private List<String> reflectionQuestions = new ArrayList<>();

    @ElementCollection(fetch = FetchType.EAGER)
    @OrderColumn(name = "tag_order")
    private List<String> tags = new ArrayList<>();

    @Column(columnDefinition = "text")
    private String contextualInterpretation;

    @Column(columnDefinition = "text")
    private String dailyAdvice;

    @ElementCollection(fetch = FetchType.EAGER)
    @OrderColumn(name = "finding_order")
    private List<String> dreamTypeFindings = new ArrayList<>();

    @Column(columnDefinition = "text")
    private String disclaimer;

    @Column(columnDefinition = "text")
    private String patternObservation;

    @Column(columnDefinition = "text")
    private String embeddingJson;

    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @PrePersist
    void onCreate() {
        createdAt = LocalDateTime.now();
    }

    public Long getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getDreamText() {
        return dreamText;
    }

    public void setDreamText(String dreamText) {
        this.dreamText = dreamText;
    }

    public String getEmotions() {
        return emotions;
    }

    public void setEmotions(String emotions) {
        this.emotions = emotions;
    }

    public String getSleepQuality() {
        return sleepQuality;
    }

    public void setSleepQuality(String sleepQuality) {
        this.sleepQuality = sleepQuality;
    }

    public Integer getStressLevel() {
        return stressLevel;
    }

    public void setStressLevel(Integer stressLevel) {
        this.stressLevel = stressLevel;
    }

    public String getPeople() {
        return people;
    }

    public void setPeople(String people) {
        this.people = people;
    }

    public String getPlaces() {
        return places;
    }

    public void setPlaces(String places) {
        this.places = places;
    }

    public String getSymbols() {
        return symbols;
    }

    public void setSymbols(String symbols) {
        this.symbols = symbols;
    }

    public String getCulturalBackground() {
        return culturalBackground;
    }

    public void setCulturalBackground(String culturalBackground) {
        this.culturalBackground = culturalBackground;
    }

    public String getBeliefs() {
        return beliefs;
    }

    public void setBeliefs(String beliefs) {
        this.beliefs = beliefs;
    }

    public String getProfession() {
        return profession;
    }

    public void setProfession(String profession) {
        this.profession = profession;
    }

    public String getRecentLifeEvents() {
        return recentLifeEvents;
    }

    public void setRecentLifeEvents(String recentLifeEvents) {
        this.recentLifeEvents = recentLifeEvents;
    }

    public String getEmotionalTone() {
        return emotionalTone;
    }

    public void setEmotionalTone(String emotionalTone) {
        this.emotionalTone = emotionalTone;
    }

    public List<String> getPossibleSymbols() {
        return possibleSymbols;
    }

    public void setPossibleSymbols(List<String> possibleSymbols) {
        this.possibleSymbols = possibleSymbols;
    }

    public List<String> getThemes() {
        return themes;
    }

    public void setThemes(List<String> themes) {
        this.themes = themes;
    }

    public List<String> getPossibleMeanings() {
        return possibleMeanings;
    }

    public void setPossibleMeanings(List<String> possibleMeanings) {
        this.possibleMeanings = possibleMeanings;
    }

    public List<String> getReflectionQuestions() {
        return reflectionQuestions;
    }

    public void setReflectionQuestions(List<String> reflectionQuestions) {
        this.reflectionQuestions = reflectionQuestions;
    }

    public List<String> getTags() {
        return tags;
    }

    public void setTags(List<String> tags) {
        this.tags = tags;
    }

    public String getContextualInterpretation() {
        return contextualInterpretation;
    }

    public void setContextualInterpretation(String contextualInterpretation) {
        this.contextualInterpretation = contextualInterpretation;
    }

    public String getDailyAdvice() {
        return dailyAdvice;
    }

    public void setDailyAdvice(String dailyAdvice) {
        this.dailyAdvice = dailyAdvice;
    }

    public List<String> getDreamTypeFindings() {
        return dreamTypeFindings;
    }

    public void setDreamTypeFindings(List<String> dreamTypeFindings) {
        this.dreamTypeFindings = dreamTypeFindings;
    }

    public String getDisclaimer() {
        return disclaimer;
    }

    public void setDisclaimer(String disclaimer) {
        this.disclaimer = disclaimer;
    }

    public String getPatternObservation() {
        return patternObservation;
    }

    public void setPatternObservation(String patternObservation) {
        this.patternObservation = patternObservation;
    }

    public String getEmbeddingJson() {
        return embeddingJson;
    }

    public void setEmbeddingJson(String embeddingJson) {
        this.embeddingJson = embeddingJson;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
}
