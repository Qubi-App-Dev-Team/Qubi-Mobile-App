# Qubi Flutter App

Demonstrates how to communicate with the Qubi over BLE

## Getting Started
To compile this project, first crate an `.env` file in the root directory of the project.
You can use the [.env.example](.env.example) file provided. Rename it to `.env` and fill in the required values.

```
SIMULATE_BLE=false
SCAN_ONLY_QUBI=true
```
`SIMULATE_BLE` can be set to `true` to simulate BLE communication for UI development.

`SCAN_ONLY_QUBI` can be set to `false` to scan for all BLE devices to verify that your BLE stack is working properly.`
