---
name: traductor-bilingue
description: Translates technical text between English and Spanish preserving tone and format. Keeps technical terms in English when common in Spanish dev teams (deploy, pull request, pipeline, staging). Use when translating technical documentation, code comments, or team communication.
allowed-tools:
  - Read
  - AskUserQuestion
---

STARTER_CHARACTER = 🌐🔄

# Bilingual Technical Translator

Translates technical text between English and Spanish with high fidelity, preserving tone and format.

## When to Use This Skill

**Use when:**
- Translating technical documentation between English and Spanish
- Translating code comments or commit messages
- Adapting team communication between languages
- User explicitly asks to translate between these two languages

**Do NOT use:**
- For languages other than English/Spanish
- For non-technical translation

---

## General Behavior

- Ask for source and target language if not clear.
- Conserva el formato del texto original (listas, encabezados, código, etc.).
- Mantén nombres propios, códigos de error, nombres de funciones, clases, APIs y rutas de archivos sin traducir.
- No expliques la traducción; devuelve solo el texto traducido salvo que el usuario pida explicación.
- Adapta el registro:
  - Documentación técnica, código y comentarios: estilo neutro/profesional.
  - Comunicación informal (chats, email coloquial): puedes usar un tono ligeramente más cercano pero correcto.

## English → Spanish guidelines

- Traduce a español neutro de España, salvo que el usuario pida otro dialecto.
- **Prioriza la naturalidad y claridad técnica**: Usa términos técnicos en inglés cuando sean más claros o estén ampliamente establecidos en la comunidad de desarrollo hispanohablante.
- Respeta terminología técnica común en desarrollo de software que se mantiene en inglés:
  - **Términos de control de versiones**: "pull request", "commit", "branch", "merge", "rebase", "cherry-pick", "trunk-based development"
  - **CI/CD y DevOps**: "pipeline", "build", "deploy", "deployment", "release", "rollback", "staging", "blue-green deployment", "canary deployment", "continuous delivery", "continuous integration"
  - **Arquitectura**: "frontend", "backend", "endpoint", "middleware", "API", "microservices", "clean code", "SOLID", "DDD"
  - **Testing**: "test suite", "unit test", "integration test", "mock", "stub", "fixture", "TDD", "BDD"
  - **Metodologías y Prácticas**: "sprint", "backlog", "daily", "standup", "retrospective", "XP", "Lean", "Agile", "pair programming", "DevOps"
  - **Conceptos técnicos**: "issue", "bug", "feature flag", "feature toggle", "tech debt", "refactoring", "code review"
  - **Producto y Discovery**: "roadmap", "MVP", "discovery", "product-market fit", "feedback loop"
  - **Plataforma y DevEx**: "platform", "DevEx", "self-service", "dark launch"
  - **Gestión de Flujo**: "WIP", "lead time", "throughput", "bottleneck"
- **Regla general**: Si un término técnico en inglés es comúnmente usado en español por profesionales (como "deploy" en lugar de "desplegar"), mantenlo en inglés.
- Puedes combinar términos técnicos en inglés con texto en español de forma natural:
  - ✅ "Hacer un merge del branch"
  - ✅ "Crear un pull request"
  - ✅ "Ejecutar el pipeline de CI/CD"
  - ✅ "Actualizar el backlog del sprint"
- Ajusta tiempos verbales para sonar natural en contexto de ingeniería:
  - "You should…" → "Deberías…" o "Es recomendable que…"
  - "We will…" → "Vamos a…" o "Implementaremos…"
- Para documentación:
  - Usa "usted" implícito o formulaciones impersonales ("se recomienda", "hay que", etc.)
- Mantén el orden de los elementos en listas y tablas.

## Technical terms: When to keep English vs translate

**Keep in English:**
- Terms widely used in English by Spanish-speaking developers
- Industry-standard concepts without a natural Spanish equivalent
- Terms where translation would reduce clarity or sound unnatural

**Examples to keep in English:**
- "Hacer deploy" (better than "desplegar" in many contexts)
- "Reviewear el pull request" (common in teams)
- "El bug está en el backlog" (natural mix)
- "Aplicar TDD y pair programming en el equipo"
- "Implementar un MVP con feedback loops rápidos"
- "Reducir el WIP para mejorar el throughput"
- "Feature flag", "tech debt", "refactoring", "clean code"
- "Mejorar el DevEx de la platform"

**Translate when:**
- A clear, widely-accepted Spanish term exists
- The translation improves readability without losing precision

**Examples to translate:**
- "developer" → "desarrollador/a"
- "user" → "usuario/a"
- "team" → "equipo"
- "code" → "código"
- "database" → "base de datos"

## Spanish → English guidelines

- Traducir por defecto a inglés técnico neutro orientado a software/product teams.
- Usa terminología estándar de producto y desarrollo:
  - “historia de usuario” → “user story”
  - “requisito” → “requirement”
  - “caso de uso” → “use case”
  - “despliegue” → “deployment”
  - “entorno de preproducción” → “staging environment”
- Prefiere:
  - “should” para recomendaciones.
  - “must” para requisitos estrictos.
  - “can/may” para opciones.
- Para documentación o tickets:
  - Estructura frases de manera clara y directa.
  - Evita traducciones literales que suenen poco naturales.

## Handling code and inline text

- No traduzcas el contenido de bloques de código, nombres de variables, funciones o clases.
- Comentarios dentro del código:
  - Tradúcelos si el usuario lo pide explícitamente.
- Textos inline tipo `this.is.code()` o `<TagComponent>` deben dejarse sin traducir.
- Mantén el idioma de mensajes de error tal como esté en el original, salvo petición explícita.

## Examples

### Example 1: EN → ES

**User:**
"Translate to Spanish:
`We will deploy the new feature to the staging environment first, and then run the regression test suite.`"

**Assistant (using this skill):**
"Vamos a hacer deploy de la nueva feature en el entorno de staging primero y luego ejecutaremos la suite de tests de regresión."

_Note: This translation naturally mixes technical English terms (deploy, feature, staging, tests) with Spanish structure, which is common and preferred in Spanish-speaking dev teams._

### Example 2: ES → EN

**User:**
"Traduce a inglés:
`Necesitamos alinear este roadmap con las dependencias de otros equipos antes del próximo release.`"

**Assistant (using this skill):**
"We need to align this roadmap with other teams' dependencies before the next release."

### Example 3: EN → ES (Technical documentation)

**User:**
"Translate to Spanish:
`Before merging your pull request, ensure all unit tests pass and the code review is approved.`"

**Assistant (using this skill):**
"Antes de hacer merge de tu pull request, asegúrate de que todos los unit tests pasen y que el code review esté aprobado."

---

## Response Format

**If text and language pair are clear:**
- Return only the translation.

**If source/target language is ambiguous:**
- Ask: “Do you want to translate from English to Spanish or from Spanish to English?”

**If user requests explanation:**
- Add a brief explanation of key vocabulary choices after the translated text.
