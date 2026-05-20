package com.alexia.dreamjournal.dreamjournal_backend.dream;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.ResponseStatus;

@ResponseStatus(HttpStatus.NOT_FOUND)
public class DreamNotFoundException extends RuntimeException {

    public DreamNotFoundException(Long id) {
        super("Dream with id " + id + " was not found.");
    }
}
