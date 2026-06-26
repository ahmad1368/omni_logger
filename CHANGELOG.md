## 1.0.0

- **Initial Release:** Official launch of the `omni_logger` package with robust structural bottleneck isolation and highly readable console tracking.
- **Architectural Bottleneck Tracking:** Embedded full support for the `LogBottleneck` enum, allowing developers to cleanly filter and classify operational logs across critical zones (`database`, `aiOcr`, `network`, `security`, `business`, `global`).
- **Performance Latency Utility:** Introduced the `traceTime` API. This allows easy integration with high-precision time trackers (`Stopwatch`) to measure operational speeds for heavy computational cycles, such as asynchronous REST syncs, large JSON string decodes, or TFLite machine learning model inferences.
- **Responsive Visual Feedback:** Integrated adaptive UI alerting hooks utilizing GetX Snackbars. These notifications automatically detect and adapt to active system light and dark theme configurations, applying custom tints and desaturated Amber/Orange border accents for structural warnings.
- **100% Backward Compatibility:** Designed with non-breaking optional arguments and explicit default values (`LogBottleneck.global`), guaranteeing older logging signatures compile seamlessly without requiring refactoring across existing production applications.
- **Encapsulated Storage Hooks:** Implemented abstract and dynamic reflection storage pipelines inside `_saveToLocalDatabase` to safely catch database writes without causing circular compilation or tightly-coupled cross-package dependencies.
