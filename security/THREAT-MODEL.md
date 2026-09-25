# WhisperLink Threat Model

## Purpose

This document defines the assets, trust boundaries, threat actors, and attack scenarios that the Stella WhisperLink security assessment must consider.

The assessment should evaluate both conventional cyber attackers and AI-driven attackers.

---

## 1. Protected Assets

The following assets must be considered security-sensitive:

### User and Session Data

- User identity
- Authentication state
- Session identifiers
- Group-session membership
- Share links and share codes
- Conversation state

### Communication Data

- Microphone/audio data
- Speech input
- Transcripts
- Translations
- Conversation history
- Messages
- Temporary communication data

### Privacy Controls

- Private/Invisible Mode
- Data-retention rules
- Deletion mechanisms
- Session expiration
- Visibility controls

### Technical Assets

- API credentials
- Third-party service credentials
- Environment variables
- Application configuration
- Service-worker data
- Browser storage
- Local caches
- IndexedDB/localStorage/sessionStorage
- Build artifacts
- Source maps
- GitHub Actions
- Dependencies

### Availability

- Translation resources
- API quota
- Session creation
- Application resources
- Network resources

---

## 2. Threat Actors

The assessment must consider the following:

### T1 — Malicious User

A normal user deliberately attempting to access data, sessions, or capabilities they are not authorized to access.

### T2 — Compromised User Account

An attacker who has obtained legitimate credentials or an active session belonging to another user.

### T3 — Malicious Client

An attacker manipulating the browser, requests, storage, parameters, or client-side state rather than using the application normally.

### T4 — Automated Attacker

Bots or automated tools attempting enumeration, abuse, brute-force activity, resource exhaustion, or repeated requests.

### T5 — Conventional Hacker

An external attacker looking for vulnerabilities in the web application, APIs, authentication, authorization, infrastructure configuration, or dependencies.

### T6 — Malicious Dependency

A compromised, vulnerable, or intentionally malicious third-party package or build dependency.

### T7 — Compromised Automation

A compromised CI/CD workflow, automation process, integration, or service attempting to access or modify resources beyond its intended permissions.

### T8 — Malicious AI Agent

An AI system intentionally or indirectly attempting to exploit application weaknesses through automated reasoning, request generation, manipulation, enumeration, or tool use.

### T9 — Prompt Injection Attacker

An attacker who places malicious instructions inside user-controlled or externally sourced content in an attempt to manipulate an AI-assisted component.

### T10 — Insider / Excessive Permission Actor

A legitimate account, integration, or automation process with more permissions than required.

---

## 3. Trust Boundaries

The assessment must explicitly examine the boundaries between:

1. User and browser
2. Browser and WhisperLink application
3. Browser and API
4. One user and another user
5. One session and another session
6. One group and another group
7. WhisperLink and third-party APIs
8. WhisperLink and the browser's local storage
9. WhisperLink and service-worker caches
10. WhisperLink and GitHub
11. WhisperLink and CI/CD automation
12. Untrusted user content and trusted application logic
13. Untrusted content and AI-assisted components

A security boundary must not rely only on client-side behavior.

---

## 4. Primary Security Questions

The assessment must determine:

### Confidentiality

Can one user access another user's:

- conversation
- transcript
- translation
- audio
- session
- account information
- private data

without authorization?

### Integrity

Can an attacker:

- modify another user's data
- alter session state
- alter permissions
- manipulate application behavior
- bypass security controls

without authorization?

### Availability

Can an attacker:

- exhaust resources
- repeatedly trigger expensive operations
- consume API quota
- create uncontrolled sessions
- cause service degradation

through realistic low-volume abuse?

### Privacy

Can WhisperLink accidentally retain, expose, cache, log, transmit, or reveal information that should have been temporary or private?

### Authentication

Can an attacker bypass, forge, reuse, steal, or manipulate authentication/session state?

### Authorization

Can an authenticated user access resources belonging to another user or group?

### AI Security

Can malicious content manipulate an AI-assisted component into crossing its intended authority boundary?

---

## 5. WhisperLink-Specific Threat Areas

The assessment must pay special attention to:

- Share codes
- Share links
- Group sessions
- Session expiration
- Private/Invisible Mode
- Temporary data
- Audio handling
- Transcript handling
- Translation handling
- Browser storage
- Service-worker caching
- API credentials
- Third-party APIs
- PWA behavior
- Rate limiting
- Dependency security
- CI/CD security
- Prompt injection
- AI-agent abuse

---

## 6. Security Goal

The goal is not to prove that WhisperLink can never be attacked.

The goal is to identify realistic attack paths, determine whether they are exploitable, understand their consequences, and strengthen the application so that the identified attack paths are blocked or significantly reduced.

Security must be enforced by the application itself and must not depend solely on the behavior or trustworthiness of an AI component.