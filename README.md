# 🛡️ Enterprise SOC & Purple Team Home Lab (Wazuh + Suricata + Shuffle SOAR)

![Wazuh](https://img.shields.io/badge/SIEM%2FXDR-Wazuh-005571?style=for-the-badge&logo=wazuh&logoColor=white)
![Suricata](https://img.shields.io/badge/NIDS-Suricata-E34F26?style=for-the-badge&logo=security&logoColor=white)
![Shuffle](https://img.shields.io/badge/SOAR-Shuffle-FF6C37?style=for-the-badge&logo=fireship&logoColor=white)
![MITRE ATT&CK](https://img.shields.io/badge/Framework-MITRE_ATT%26CK-C8102E?style=for-the-badge&logo=target&logoColor=white)
![Ubuntu](https://img.shields.io/badge/Environment-Ubuntu_Server_%7C_Docker-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)

## 📌 Overview

This repository documents the architecture, custom detection rules, and automated response workflows of my personal **Security Operations Center (SOC) & Purple Team Home Lab**. 

Built on a virtualized Linux infrastructure (**VMware Workstation Pro** & **Docker**), this lab simulates real-world attack scenarios (Red Team) to engineer, test, and fine-tune high-fidelity detection rules and **SOAR playbooks** (Blue Team).

---

## 🏗️ Lab Architecture & Telemetry Flow

1. **🔴 Attack Simulation (Red Team):** Controlled adversary emulation from **Kali Linux / Parrot OS** executing SSH Brute Force, Nmap SYN Scans, and web exploitation against an **Ubuntu Server** target.
2. **🔵 Telemetry & Sensors (Blue Team):**
   - **Wazuh Agent:** Collects host logs (`/var/log/auth.log`, `syslog`), File Integrity Monitoring (FIM), and system calls.
   - **Suricata NIDS:** Inspects network traffic in real time and outputs JSON alerts (`eve.json`) ingested directly by the Wazuh Agent.
3. **🟣 SIEM & Correlation:** **Wazuh Manager & Indexer** correlate host and network events, mapping alerts directly to **MITRE ATT&CK** tactics and techniques.
4. **⚡ SOAR & Automated Response:** High-severity alerts trigger a webhook to **Shuffle SOAR**, which automatically queries **VirusTotal / AbuseIPDB** APIs for IOC reputation and triggers **Wazuh Active Response** (`firewall-drop`) to block the attacker's IP.

---

## 🧰 Core Components

| Component | Role | Deployment | Description |
| :--- | :--- | :--- | :--- |
| **Wazuh** | SIEM / XDR | Ubuntu Server / Docker | Log aggregation, File Integrity Monitoring (FIM), vulnerability detection, and MITRE ATT&CK correlation. |
| **Suricata** | NIDS | Ubuntu Server | Real-time network packet inspection, signature matching (`Emerging Threats`), and JSON (`eve.json`) log forwarding to Wazuh. |
| **Shuffle** | SOAR | Docker Container | Automated playbooks triggered via Wazuh webhooks for IOC reputation checks and active response execution. |
| **Custom Scripts** | Automation | Go & Python | Log parsers, custom enrichment scripts, and baseline validation tools. |
| **Kali / Parrot OS** | Adversary Emulation | VMware VM | Execution of controlled attacks mapped to MITRE ATT&CK techniques to validate detection coverage. |

---

## 🎯 Use Cases & Detection Engineering Showcase

### Use Case 01: SSH Brute-Force Detection & Automated IP Blocking
- **MITRE ATT&CK:** `T1110.001` (Brute Force: Password Guessing)
- **Attack Simulation:** Executed automated SSH authentication attempts from Kali Linux against the Ubuntu Server target.
- **Detection Logic:** 
  - Wazuh ingests `/var/log/auth.log` and triggers high-severity correlation rule `5712` after multiple failed logins within a short time window.
  - Suricata inspects anomalous SSH handshake rates on port `22`.
- **Shuffle SOAR Playbook:**
  1. Wazuh sends the alert JSON payload to **Shuffle** via Webhook.
  2. Shuffle extracts the `srcip` field and queries the **AbuseIPDB API** for threat intelligence enrichment.
  3. Shuffle triggers **Wazuh Active Response** (`firewall-drop`) to dynamically block the attacker's IP via `iptables`/`ufw` on the target host.

---

### Use Case 02: Network Reconnaissance & Port Scanning
- **MITRE ATT&CK:** `T1046` (Network Service Discovery)
- **Attack Simulation:** Performed SYN Stealth Scans (`nmap -sS`) and service enumeration against internal lab subnets.
- **Detection Logic:**
  - **Suricata NIDS** detects abnormal SYN packet rates and triggers signature alerts in `/var/log/suricata/eve.json`.
  - **Wazuh** parses the `eve.json` output, correlates the source IP, and visualizes the event on the Security Events dashboard.

---

## 🚀 Key Skills Demonstrated
- **SIEM Administration:** Rule tuning, custom XML decoders, and reducing false positives in Wazuh.
- **Network Security Monitoring (NSM):** Configuring Suricata interfaces, rule management, and inspecting PCAPs.
- **SOAR Orchestration:** Building workflows in **Shuffle**, REST API integrations, and automated incident containment.
- **Linux Hardening:** Securing Ubuntu Server endpoints, managing systemd services, and firewall rules.

---
*Developed and maintained by **Rafael Laporte** – [LinkedIn](https://www.linkedin.com/in/rafaellaporte)*
