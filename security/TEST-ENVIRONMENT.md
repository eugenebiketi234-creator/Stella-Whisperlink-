# WhisperLink Security Test Environment

## Project

Stella Tech — WhisperLink

## Security Branch

security/whisperlink-red-team-v1

## Assessment Type

Authorized defensive security assessment and controlled red-team testing.

---

# 1. Authorized Source

The primary source for the assessment is the WhisperLink code contained in this repository and the version represented by the security branch.

The security assessment must first understand the actual application architecture before attempting runtime testing.

---

# 2. Runtime Environment

Runtime security testing should be performed against a dedicated WhisperLink staging/test deployment.

PRODUCTION IS NOT THE DEFAULT SECURITY-TEST TARGET.

If a staging URL has not yet been provided, perform source-code analysis first and request the staging URL before performing runtime testing.

---

# 3. Staging Environment

STAGING_URL:

[TO BE PROVIDED]

Do not invent or assume a staging URL.

---

# 4. Production Environment

PRODUCTION_URL:

[TO BE PROVIDED]

Production must be treated as OFF LIMITS unless the owner explicitly authorizes a specific test.

Do not perform penetration testing against production by default.

---

# 5. Test Accounts

Use synthetic accounts for security testing.

Recommended accounts:

- SECURITY-USER-A
- SECURITY-USER-B
- SECURITY-ADMIN

These accounts exist only for authorized security testing.

Do not use real customer accounts.

---

# 6. Test Data

Use synthetic test data.

Recommended identifiers:

- TEST-CONVERSATION-A
- TEST-CONVERSATION-B
- TEST-GROUP-A
- TEST-GROUP-B
- TEST-AUDIO-A
- TEST-TRANSCRIPT-A
- TEST-TRANSLATION-A

Do not use real personal conversations, real sensitive audio, or real personal information.

---

# 7. Test Credentials

Security testing credentials must be created specifically for the test environment.

Never place real production credentials in this document.

Never commit API keys, passwords, access tokens, private keys, or other secrets to this repository.

---

# 8. Third-Party Services

WhisperLink may interact with third-party services.

Third-party services must NOT themselves become penetration-testing targets.

Testing should focus on:

- How WhisperLink communicates with the service
- What credentials WhisperLink exposes
- What data WhisperLink sends
- What data WhisperLink accepts
- Whether the integration is securely implemented
- Whether an attacker can abuse the WhisperLink integration

Do not attack or attempt unauthorized access to the third-party service itself.

---

# 9. Testing Boundaries

The following are IN SCOPE:

- WhisperLink source code
- WhisperLink frontend
- WhisperLink backend/API components
- WhisperLink staging deployment
- WhisperLink browser behavior
- WhisperLink PWA
- WhisperLink service worker
- WhisperLink storage
- WhisperLink session management
- WhisperLink share mechanisms
- WhisperLink authentication and authorization
- WhisperLink security configuration
- WhisperLink dependencies
- WhisperLink CI/CD configuration

The following are OUT OF SCOPE:

- WhatsApp
- GitHub infrastructure
- Deepgram infrastructure
- Vercel infrastructure
- Other companies' infrastructure
- Other users' systems
- Unrelated websites
- Unrelated APIs
- Production systems unless explicitly authorized

---

# 10. Safe Testing Rules

Security testing must be controlled and non-destructive.

Do not:

- Destroy data
- Delete real user information
- Exfiltrate real personal information
- Steal real credentials
- Establish persistence
- Deploy malware
- Attack third-party systems
- Perform destructive denial-of-service
- Intentionally disrupt production
- Modify production without explicit authorization

Use the minimum proof necessary to demonstrate a vulnerability.

---

# 11. Evidence Handling

Security findings may contain sensitive technical information.

Do not include:

- Real passwords
- Real API keys
- Private keys
- Authentication tokens
- Real personal information

Secrets must be redacted.

Synthetic identifiers should be used wherever possible.

---

# 12. Security Assessment State

Current state:

INITIAL SECURITY SETUP

The initial assessment has not yet been authorized to modify WhisperLink code.

During the assessment phase:

- Source code may be inspected
- Configuration may be inspected
- Dependencies may be inspected
- Authorized staging behavior may be tested
- Vulnerabilities may be documented
- Remediation may be proposed

Code changes require explicit authorization.

---

# 13. Remediation Authorization

After the initial assessment, Claude must produce:

1. Security Assessment Report
2. Remediation Plan

Claude must then STOP.

No code modifications are permitted until the owner explicitly authorizes remediation.

Authorization phrase:

AUTHORIZE REMEDIATION

---

# 14. Retesting

After authorized fixes are implemented, the same security tests should be repeated.

A finding should only be marked FIXED when evidence demonstrates that:

- The original attack path no longer works, or
- The vulnerable security boundary has been redesigned so that the original attack is no longer applicable.

---

# 15. Security Objective

The objective is to make WhisperLink resilient against:

- Conventional hackers
- Malicious users
- Automated attackers
- Compromised sessions
- Malicious clients
- Malicious dependencies
- Compromised automation
- Prompt injection
- Indirect prompt injection
- Malicious AI agents
- Future autonomous attack systems

Security must be enforced by WhisperLink itself and must not depend solely on an AI system behaving correctly.