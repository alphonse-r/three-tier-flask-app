document.querySelectorAll('.edit-form').forEach(form => {
    const editBtn = form.querySelector('.edit-btn');
    const applyBtn = form.querySelector('.apply-btn');
    const input = form.querySelector('.edit-input');
    const nameSpan = form.querySelector('.person-name');

    editBtn.addEventListener('click', () => {
        // Affiche l'input avec la valeur actuelle
        input.style.display = 'inline-block';
        nameSpan.style.display = 'none';

        // Boutons
        editBtn.style.display = 'none';
        applyBtn.style.display = 'inline-block';
    });

    applyBtn.addEventListener('click', () => {
        // Le formulaire POST est envoyé automatiquement
    });
});

