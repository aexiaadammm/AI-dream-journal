# AI endpoint examples

## Environment variables

```powershell
$env:OPENAI_API_KEY="your_api_key_here"
$env:OPENAI_MODEL="gpt-5.4-mini"
$env:OPENAI_EMBEDDING_MODEL="text-embedding-3-small"
```

## POST /api/assistant/chat

Request:

```json
{
  "userId": "alexia",
  "dreamId": 12,
  "message": "Why do I keep dreaming about water?",
  "dreamText": "I was crossing a bridge over dark water.",
  "emotions": "fear, curiosity",
  "sleepQuality": "Interrupted",
  "stressLevel": 7,
  "people": "my friend",
  "places": "bridge, river",
  "symbols": "water, bridge",
  "culturalBackground": "Balkan",
  "beliefs": "Symbolic",
  "profession": "teacher",
  "recentLifeEvents": "I started a new job."
}
```

Response:

```json
{
  "possibleInterpretation": "The water could reflect emotional uncertainty, while the bridge may suggest a transition.",
  "emotionalThemes": ["uncertainty", "transition", "curiosity"],
  "reflectionQuestions": ["What feels like a crossing point in your life right now?"],
  "patternObservation": "Am observat că în mai multe vise apare tema schimbării.",
  "companionMessage": "It may help to write down what the bridge connects in your dream.",
  "disclaimer": "This is a reflective interpretation, not a medical or psychological diagnosis."
}
```

## POST /api/dreams/{id}/analyze

Request:

```json
{
  "userId": "alexia",
  "dreamText": "I was crossing a bridge over dark water.",
  "emotions": "fear, curiosity",
  "sleepQuality": "Interrupted",
  "stressLevel": 7,
  "people": "my friend",
  "places": "bridge, river",
  "symbols": "water, bridge",
  "culturalBackground": "Balkan",
  "beliefs": "Symbolic",
  "profession": "teacher",
  "recentLifeEvents": "I started a new job."
}
```

Response:

```json
{
  "emotionalTone": "tense but searching",
  "themes": ["transition", "uncertainty", "emotional processing"],
  "symbols": ["water", "bridge"],
  "possibleMeanings": ["The bridge may point to movement between two life stages."],
  "reflectionQuestions": ["What change currently feels both necessary and intimidating?"],
  "tags": ["transition", "water", "stress"],
  "patternObservation": "Am observat că în mai multe vise apare tema trecerii printr-un spațiu nesigur."
}
```
