enum AssistantMode {
  reflection,
  creativeTransformation,
}

extension AssistantModeLabel on AssistantMode {
  String get label {
    return switch (this) {
      AssistantMode.reflection => 'Reflection',
      AssistantMode.creativeTransformation => 'Creative Transformation',
    };
  }
}
