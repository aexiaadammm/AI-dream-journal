package com.alexia.dreamjournal.dreamjournal_backend.ai;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Component
@ConfigurationProperties(prefix = "openai")
public class OpenAIProperties {

    private String apiKey;
    private String provider;
    private String model;
    private String embeddingModel;
    private String responsesUrl;
    private String embeddingsUrl;

    public String getApiKey() {
        return apiKey;
    }

    public void setApiKey(String apiKey) {
        this.apiKey = apiKey;
    }

    public String getProvider() {
        return provider;
    }

    public void setProvider(String provider) {
        this.provider = provider;
    }

    public boolean useOpenAI() {
        return "openai".equalsIgnoreCase(provider);
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public String getEmbeddingModel() {
        return embeddingModel;
    }

    public void setEmbeddingModel(String embeddingModel) {
        this.embeddingModel = embeddingModel;
    }

    public String getResponsesUrl() {
        return responsesUrl;
    }

    public void setResponsesUrl(String responsesUrl) {
        this.responsesUrl = responsesUrl;
    }

    public String getEmbeddingsUrl() {
        return embeddingsUrl;
    }

    public void setEmbeddingsUrl(String embeddingsUrl) {
        this.embeddingsUrl = embeddingsUrl;
    }
}
