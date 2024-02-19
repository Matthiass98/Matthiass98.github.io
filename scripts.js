document.addEventListener("DOMContentLoaded", function() {
    // Example of adding more interactivity with JavaScript
    const navLinks = document.querySelectorAll('nav a[href^="#"]');
    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            let target = document.querySelector(this.getAttribute('href'));
            window.scrollTo({
                top: target.offsetTop,
                behavior: "smooth"
            });
        });
    });

    // Additional JavaScript can be added here to enhance interactivity
    // For example, loading projects dynamically, form validation, etc.
});
