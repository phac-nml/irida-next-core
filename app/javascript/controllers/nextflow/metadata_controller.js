import { Controller } from "@hotwired/stimulus";

// Handles sending metadata to samplesheet after metadata selection
export default class extends Controller {
  static values = {
    metadata: { type: Object },
    property: { type: String },
  };

  connect() {
    this.sendMetadata();
  }

  sendMetadata() {
    this.dispatch("sendMetadata", {
      detail: {
        content: { metadata: this.metadataValue, property: this.propertyValue },
      },
    });
  }
}
