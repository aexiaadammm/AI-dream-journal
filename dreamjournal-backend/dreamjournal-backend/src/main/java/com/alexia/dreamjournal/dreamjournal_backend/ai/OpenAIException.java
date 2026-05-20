package com.alexia.dreamjournal.dreamjournal_backend.ai;

public class OpenAIException extends RuntimeException {

    public OpenAIException(String message) {
        super(message);
    }

    public OpenAIException(String message, Throwable cause) {
        super(message, cause);
    }
}
