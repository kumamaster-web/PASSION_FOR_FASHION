document.addEventListener("DOMContentLoaded", () => {
  const uploadBox = document.querySelector(".upload-box");
  const input = document.querySelector(".file-input");

  if (!uploadBox || !input) return;

  uploadBox.addEventListener("dragover", (e) => {
    e.preventDefault();
    uploadBox.classList.add("dragover");
  });

  uploadBox.addEventListener("dragleave", () => {
    uploadBox.classList.remove("dragover");
  });

  uploadBox.addEventListener("drop", (e) => {
    e.preventDefault();
    uploadBox.classList.remove("dragover");
    input.files = e.dataTransfer.files;
  });
});
