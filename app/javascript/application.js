// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"
import "./controllers/upload"

document.addEventListener("turbo:load", () =>{
  const form = document.getElementById("fashion-quiz-form");
  const overlay = document.getElementById("ai-loading-overlay");

  if (form && overlay) {
    form.addEventListener("submit", () => {
      overlay.classList.remove("hidden");
    });
  }
});
