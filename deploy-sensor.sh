#!/usr/bin/env bash
# ==============================================================================
# Script Name: deploy-sensor.sh
# Description: Automates Suricata NIDS & Wazuh Agent log integration on Ubuntu
# Author:      Rafael Laporte (github.com/rcybershield)
# Environment: Ubuntu Server 24.04 LTS (SOC & Purple Team Home Lab)
# ==============================================================================

set -euo pipefail

SURICATA_LOG="/var/log/suricata/eve.json"
OSSEC_CONF="/var/ossec/etc/ossec.conf"
LOCAL_RULES_SRC="./local_rules.xml"
LOCAL_RULES_DEST="/var/ossec/etc/rules/local_rules.xml"

echo "============================================================="
echo " 🛡️  SOC HOME LAB | Wazuh & Suricata Sensor Provisioning"
echo "============================================================="

# 1. Verify root privileges
if [[ $EUID -ne 0 ]]; then
   echo "[!] Error: This script must be executed as root (use sudo)."
   exit 1
fi

# 2. Verify Suricata eve.json telemetry file exists
echo "[*] Checking Suricata NIDS telemetry output..."
if [[ -f "$SURICATA_LOG" ]]; then
    echo "[+] Suricata EVE JSON log found at: $SURICATA_LOG"
else
    echo "[!] Warning: $SURICATA_LOG not found. Ensure Suricata service is active."
fi

# 3. Configure Wazuh Agent to ingest Suricata eve.json
echo "[*] Checking Wazuh Agent ossec.conf for Suricata ingestion..."
if [[ -f "$OSSEC_CONF" ]]; then
    if grep -q "$SURICATA_LOG" "$OSSEC_CONF"; then
        echo "[+] Suricata log collector is already configured in $OSSEC_CONF."
    else
        echo "[*] Injecting Suricata JSON log collector block into $OSSEC_CONF..."
        cat <<EOF >> "$OSSEC_CONF"

<!-- Suricata NIDS Telemetry Integration -->
<ossec_config>
  <localfile>
    <log_format>json</log_format>
    <location>/var/log/suricata/eve.json</location>
  </localfile>
</ossec_config>
EOF
        echo "[+] Successfully added Suricata collector to Wazuh configuration."
    fi
fi

# 4. Deploy Custom Detection Rules (if running on Wazuh Manager)
if [[ -f "$LOCAL_RULES_SRC" && -d "/var/ossec/etc/rules" ]]; then
    echo "[*] Deploying custom MITRE ATT&CK detection rules ($LOCAL_RULES_SRC)..."
    cp "$LOCAL_RULES_SRC" "$LOCAL_RULES_DEST"
    chown wazuh:wazuh "$LOCAL_RULES_DEST" 2>/dev/null || true
    chmod 660 "$LOCAL_RULES_DEST"
    echo "[+] Custom rules deployed to $LOCAL_RULES_DEST"
fi

# 5. Restart services to apply telemetry changes
echo "[*] Restarting Suricata and Wazuh services..."
systemctl restart suricata 2>/dev/null || echo "[i] Suricata service restart skipped."
systemctl restart wazuh-agent 2>/dev/null || systemctl restart wazuh-manager 2>/dev/null || echo "[i] Wazuh service restart skipped."

echo "============================================================="
echo " [+] Sensor provisioning complete! Telemetry is active."
echo "============================================================="
