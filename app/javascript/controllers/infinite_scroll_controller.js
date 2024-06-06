import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static outlets = ["selection"];
  static targets = ["all", "pageForm", "pageFormContent", "scrollable"];

  #page = 1;

  connect() {
    this.allIds = this.selectionOutlet.getStoredSamples();
    this.submitForm();
    this.#makeAllHiddenInputs();
  }

  scroll() {
    if (
      this.scrollableTarget.scrollHeight - this.scrollableTarget.scrollTop <=
      this.scrollableTarget.clientHeight + 1
    ) {
      this.submitForm();
    }
  }

  #makePagedHiddenInputs() {
    const itemsPerPage = 100;
    const start = (this.#page - 1) * itemsPerPage;
    const end = this.#page * itemsPerPage;
    const ids = this.allIds.slice(start, end);
    const fragment = document.createDocumentFragment();
    for (const id of ids) {
      fragment.appendChild(
        this.#createHiddenInput("sample_ids[]", id),
      );
    }
    fragment.appendChild(
      this.#createHiddenInput("page", this.#page),
    );
    fragment.appendChild(
      this.#createHiddenInput("has_next", ids.length === itemsPerPage),
    );
    fragment.appendChild(
      this.#createHiddenInput("format", "turbo_stream"),
    );
    this.pageFormContentTarget.appendChild(fragment);
    this.#page++;
  }

  #makeAllHiddenInputs() {
    const fragment = document.createDocumentFragment();
    for (const id of this.allIds) {
      fragment.appendChild(this.#createHiddenInput("transfer[sample_ids][]", id)); //TODO: fix name
    }
    this.allTarget.appendChild(fragment);
  }

  #createHiddenInput(name, value) {
    const element = document.createElement("input");
    element.type = "hidden";
    element.id = name;
    element.name = name;
    element.value = value;
    return element;
  }

  submitForm() {
    this.#makePagedHiddenInputs();
    this.pageFormTarget.requestSubmit();
  }

  clear(){
    this.selectionOutlet.clear();
  }
}
