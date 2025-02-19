---

# Prometheus Metric Blacklist Configuration Guide

## Overview

This guide provides step-by-step instructions on how to configure Prometheus to drop specific metrics using relabeling configurations. This is particularly useful for optimizing performance by excluding unnecessary metrics from being stored and processed.

## Prerequisites

- Prometheus installed and running
- Basic knowledge of YAML and Prometheus configuration files
- Access to the Prometheus configuration file (`/etc/prometheus/prometheus.yml`)

---

## 1. **Configuring Metric Relabeling**

### 1.1 **Edit the Prometheus Configuration File**

To begin, you need to modify the Prometheus configuration file to include the metric relabeling section. This section will define which metrics should be dropped.

1. **Open the Prometheus configuration file:**

   ```bash
   sudo nano /etc/prometheus/prometheus.yml
   ```

2. **Locate the `scrape_configs` section** where your scrape jobs are defined. You will add the `metric_relabel_configs` block under the appropriate job (e.g., Node Exporter).

### 1.2 **Example Configuration**

Below is an example configuration that shows how to drop specific metrics in Prometheus:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
  - static_configs:
    - targets: ['localhost:19097']

rule_files:
  - /etc/prometheus/linux.yml
  - /etc/prometheus/linux1.yml
  - /etc/prometheus/linux2.yml

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:19091']
        labels:
          instance: 'prometheus'

  - job_name: 'local_node_exporter'
    static_configs:
      - targets: ['localhost:19095']
        labels:
          instance: 'node1'
    metric_relabel_configs:         # Relabeling configuration to drop specific metrics
      - source_labels: [__name__]
        regex: 'go_memstats_mallocs_total|node_entropy_pool_size_bits|node_boot_time_seconds|node_cpu_guest_seconds_total|node_cpu_seconds_total'
        action: drop

  - job_name: 'remote_node_exporter'
    static_configs:
      - targets: ['192.168.1.181:19095']
        labels:
          instance: 'node2'
    metric_relabel_configs:         # Relabeling configuration to drop specific metrics
      - source_labels: [__name__]
        regex: 'go_memstats_mallocs_total|node_entropy_pool_size_bits|node_boot_time_seconds|node_cpu_guest_seconds_total|node_cpu_seconds_total'
        action: drop
```

### 1.3 **Explanation**

- **source_labels**: Specifies the label or labels to match against. Here, `__name__` is used, which refers to the metric name.
- **regex**: A regular expression pattern that matches the metric names you want to drop. In this example, several metrics related to memory, CPU, and system boot time are being dropped.
- **action**: The action to take when a match is found. The `drop` action excludes the matched metrics from being scraped or stored.

---

## 2. **Apply the Configuration**

After editing the file and adding the metric relabeling configurations:

1. **Save and close** the configuration file.

2. **Reload Prometheus** to apply the changes:

   ```bash
   sudo systemctl reload prometheus
   ```

---

## 3. **Verifying the Configuration**

1. **Check Prometheus logs** to ensure there are no errors:

   ```bash
   sudo tail -f /var/log/syslog | grep prometheus
   ```

2. **Verify in the Prometheus Web UI**:
   - Visit the Prometheus web UI.
   - Search for the metrics you configured to drop.
   - Confirm that these metrics are no longer present.

---

## Conclusion

By following this guide, you’ve successfully configured Prometheus to drop specific metrics, helping to reduce unnecessary data processing and storage. This can be especially beneficial for optimizing performance in environments with large-scale metric collections.

---



---

# Prometheus Metric Whitelist Configuration Guide

## Overview

This guide provides a step-by-step process to configure Prometheus to keep only specific metrics using metric relabeling. This approach helps optimize data collection by focusing on essential metrics while discarding others.

## Prerequisites

- Prometheus installed and running
- Basic understanding of YAML and Prometheus configuration files
- Access to the Prometheus configuration file (`/etc/prometheus/prometheus.yml`)

---

## 1. **Editing the Prometheus Configuration**

### 1.1 **Open the Configuration File**

First, access your Prometheus configuration file:

```bash
sudo nano /etc/prometheus/prometheus.yml
```

### 1.2 **Locate the Scrape Configurations**

Find the `scrape_configs` section, which defines your scrape jobs. This is where you will configure metric whitelisting for specific targets.

### 1.3 **Add Metric Relabeling Configurations**

For each job (e.g., Node Exporter), you can add a `metric_relabel_configs` block to specify which metrics should be kept. Here’s how to do it:

#### **Example Configuration**

Below is an example configuration for Prometheus, including metric relabeling to keep specific metrics:

```yaml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
  - static_configs:
    - targets: ['localhost:19097']

rule_files:
  - /etc/prometheus/linux.yml
  - /etc/prometheus/linux1.yml
  - /etc/prometheus/linux2.yml

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:19091']
        labels:
          instance: 'prometheus'

  - job_name: 'local_node_exporter'
    static_configs:
      - targets: ['localhost:19095']
        labels:
          instance: 'erp'
    metric_relabel_configs:
      - source_labels: [__name__]
        regex: 'go_memstats_mallocs_total|node_entropy_pool_size_bits|node_boot_time_seconds|node_cpu_guest_seconds_total'
        action: keep

  - job_name: 'remote_node_exporter'
    static_configs:
      - targets: ['192.168.1.181:19095']
        labels:
          instance: 'node1'
    metric_relabel_configs:
      - source_labels: [__name__]
        regex: 'go_memstats_mallocs_total|node_entropy_pool_size_bits|node_boot_time_seconds|node_cpu_guest_seconds_total'
        action: keep
```

### 1.4 **Explanation of the Configuration**

- **source_labels**: Identifies the label or labels to match. `__name__` refers to the metric name.
- **regex**: The regular expression pattern that matches the metric names you want to keep. In this example, only memory stats, entropy pool size, boot time, and CPU guest seconds metrics are kept.
- **action**: The action to take when a match is found. The `keep` action retains the matched metrics and discards others.

---

## 2. **Apply the Configuration**

### 2.1 **Save and Close the File**

After making the necessary changes, save the file and exit the editor.

### 2.2 **Reload Prometheus**

Reload Prometheus to apply the new configuration:

```bash
sudo systemctl reload prometheus
```

---

## 3. **Verifying the Configuration**

### 3.1 **Check the Prometheus Logs**

Ensure there are no errors by checking the Prometheus logs:

```bash
sudo tail -f /var/log/syslog | grep prometheus
```

### 3.2 **Verify in the Prometheus Web UI**

Access the Prometheus web UI and search for the metrics you configured to be kept to verify that they are being collected as expected.

---

## Conclusion

By following this guide, you've successfully configured Prometheus to keep only specific metrics, allowing for more efficient and focused monitoring. This approach is particularly useful for reducing the load on Prometheus and focusing on key performance indicators.

---
