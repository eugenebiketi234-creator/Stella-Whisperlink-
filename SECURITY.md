# Stella WhisperLink Security

## Purpose

This repository contains Stella WhisperLink and its authorized security-testing materials.

The purpose of this security program is to identify, safely demonstrate, report, remediate, and retest vulnerabilities affecting WhisperLink.

WhisperLink must be designed to resist both conventional cyber attackers and future AI-driven attackers.

## Authorized Security Testing

Security testing is authorized only against:

- The WhisperLink source code in this repository
- Explicitly authorized WhisperLink staging/test deployments
- Synthetic test accounts
- Synthetic test conversations and data
- Test credentials created specifically for security testing
- Security test infrastructure explicitly designated for WhisperLink

## Prohibited Targets

Security testing must not target:

- WhatsApp
- GitHub infrastructure
- Deepgram infrastructure
- Vercel infrastructure
- Other companies' systems
- Other users' systems or data
- Unrelated websites or services
- Production systems unless explicitly authorized

## Testing Principles

Security testing must:

- Be controlled and non-destructive
- Use synthetic data whenever possible
- Minimize data exposure
- Never intentionally destroy data
- Never establish persistence
- Never expose real secrets
- Never exfiltrate real personal information
- Stop once sufficient evidence demonstrates a vulnerability

## AI Security

WhisperLink must not depend on an AI system being trustworthy as its security boundary.

Application-level controls must independently enforce:

- Authentication
- Authorization
- Session isolation
- Privacy
- Credential protection
- Data lifecycle rules
- Rate limiting
- Input validation
- Security boundaries

AI-related testing should consider:

- Prompt injection
- Indirect prompt injection
- Malicious AI agents
- Compromised automation
- AI-assisted abuse
- Untrusted AI-generated or user-generated content

## Remediation Policy

Security findings must be reported before remediation.

The security assessment process is:

1. Assess
2. Safely reproduce where possible
3. Report
4. Propose remediation
5. Stop and wait for explicit authorization
6. Implement approved fixes
7. Retest
8. Produce the final remediation report

No security fix should be silently applied during the initial assessment.

## Secrets

Never commit passwords, API keys, access tokens, private keys, or other sensitive credentials to this repository.

Sensitive credentials must be stored using appropriate secret-management mechanisms.