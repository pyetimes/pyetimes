{{
    use crate::web::components::{ 
        Meta,
        Header,
        Footer,
    };
}}
<!DOCTYPE html>
<html>
    <head>
        {{ 
            Meta {
                title: "Búsqueda - PyE Times",
                description: "Busca artículos, tags y secciones en PyE Times.",
                ..Default::default()
            }
        }}
        
        <!-- Styles -->
        <link rel="stylesheet" href="/css/global.css" />
        <link rel="stylesheet" href="/css/layout.css" />

        <!-- Scripts -->
        <script src="/js/web_components.js"></script>
    </head>
    <body>
        <div class="main-wrapper">
            {{ Header {} }}

            <div class="container">
                <div class="search-container">
                    <h1 class="search-title">Búsqueda de Artículos</h1>
                    
                    <div class="search-form">
                        <div class="search-input-group">
                            <input type="text" id="search-query" placeholder="Buscar artículos..." />
                            <button id="search-button" class="search-button">Buscar</button>
                        </div>
                        
                        <div class="search-filters">
                            <div class="filter-group">
                                <label for="filter-section">Sección:</label>
                                <select id="filter-section">
                                    <option value="">Todas las secciones</option>
                                </select>
                            </div>
                            
                            <div class="filter-group">
                                <label for="filter-tag">Tag:</label>
                                <input type="text" id="filter-tag" placeholder="Buscar por tag..." />
                            </div>
                        </div>
                    </div>

                    <div id="search-results" class="search-results">
                        <p class="help-text">Ingresa un término de búsqueda o selecciona filtros para comenzar.</p>
                    </div>

                    <div id="pagination" class="pagination" style="display: none;">
                        <button id="prev-page" class="page-button" disabled>← Anterior</button>
                        <span id="page-info"></span>
                        <button id="next-page" class="page-button">Siguiente →</button>
                    </div>
                </div>
            </div>
        </div>

        <style>
            .search-container {
                max-width: 900px;
                margin: 0 auto;
                padding: 20px 0;
            }

            .search-title {
                font-size: 36px;
                margin-bottom: 30px;
                text-align: center;
            }

            .search-form {
                background: var(--color-bg-secondary);
                padding: 30px;
                border-radius: 8px;
                margin-bottom: 40px;
            }

            .search-input-group {
                display: flex;
                gap: 10px;
                margin-bottom: 20px;
            }

            .search-input-group input {
                flex: 1;
                padding: 12px 16px;
                font-size: 16px;
                border: 1px solid var(--color-border);
                border-radius: 4px;
                background: var(--color-bg-primary);
                color: var(--color-text-primary);
            }

            .search-button {
                padding: 12px 32px;
                background: var(--color-accent);
                color: white;
                border: none;
                border-radius: 4px;
                font-size: 16px;
                font-weight: bold;
                cursor: pointer;
                transition: opacity 0.2s;
            }

            .search-button:hover {
                opacity: 0.9;
            }

            .search-filters {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 20px;
            }

            .filter-group {
                display: flex;
                flex-direction: column;
                gap: 8px;
            }

            .filter-group label {
                font-weight: bold;
                font-size: 14px;
                color: var(--color-text-secondary);
            }

            .filter-group select,
            .filter-group input {
                padding: 10px 12px;
                border: 1px solid var(--color-border);
                border-radius: 4px;
                background: var(--color-bg-primary);
                color: var(--color-text-primary);
                font-size: 14px;
            }

            .search-results {
                min-height: 300px;
            }

            .help-text {
                text-align: center;
                color: var(--color-text-secondary);
                padding: 60px 20px;
                font-style: italic;
            }

            .loading-text {
                text-align: center;
                color: var(--color-text-secondary);
                padding: 60px 20px;
            }

            .result-card {
                background: var(--color-bg-secondary);
                padding: 24px;
                border-radius: 8px;
                margin-bottom: 20px;
                border: 1px solid var(--color-border);
                transition: transform 0.2s, box-shadow 0.2s;
            }

            .result-card:hover {
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            }

            .result-card h3 {
                margin: 0 0 10px 0;
                font-size: 24px;
            }

            .result-card h3 a {
                color: var(--color-text-primary);
                text-decoration: none;
            }

            .result-card h3 a:hover {
                color: var(--color-accent);
            }

            .result-excerpt {
                color: var(--color-text-secondary);
                margin: 0 0 15px 0;
                line-height: 1.6;
            }

            .result-meta {
                display: flex;
                gap: 20px;
                font-size: 14px;
                color: var(--color-text-secondary);
            }

            .result-tags {
                display: flex;
                flex-wrap: wrap;
                gap: 8px;
                margin-top: 12px;
            }

            .tag {
                background: var(--color-accent);
                color: white;
                padding: 4px 10px;
                border-radius: 12px;
                font-size: 12px;
                text-decoration: none;
            }

            .tag:hover {
                opacity: 0.8;
            }

            .pagination {
                display: flex;
                justify-content: center;
                align-items: center;
                gap: 20px;
                margin-top: 40px;
            }

            .page-button {
                padding: 10px 20px;
                background: var(--color-accent);
                color: white;
                border: none;
                border-radius: 4px;
                cursor: pointer;
                transition: opacity 0.2s;
            }

            .page-button:hover:not(:disabled) {
                opacity: 0.9;
            }

            .page-button:disabled {
                background: var(--color-border);
                cursor: not-allowed;
                opacity: 0.5;
            }

            .no-results {
                text-align: center;
                padding: 60px 20px;
            }

            .no-results h2 {
                color: var(--color-text-primary);
                margin-bottom: 10px;
            }

            .no-results p {
                color: var(--color-text-secondary);
            }

            @media (max-width: 768px) {
                .search-filters {
                    grid-template-columns: 1fr;
                }

                .search-input-group {
                    flex-direction: column;
                }
            }
        </style>

        {{ Footer {} }}

        <script>
            let currentPage = 0;
            let totalResults = 0;
            const resultsPerPage = 20;
            let currentQuery = '';
            let currentSection = '';
            let currentTag = '';

            document.addEventListener('DOMContentLoaded', function() {
                loadSections();
                
                // Search on button click
                document.getElementById('search-button').addEventListener('click', performSearch);
                
                // Search on Enter key
                document.getElementById('search-query').addEventListener('keypress', function(e) {
                    if (e.key === 'Enter') {
                        performSearch();
                    }
                });

                // Filter by tag on Enter
                document.getElementById('filter-tag').addEventListener('keypress', function(e) {
                    if (e.key === 'Enter') {
                        searchByTag();
                    }
                });

                // Section filter change
                document.getElementById('filter-section').addEventListener('change', function() {
                    if (this.value) {
                        searchBySection();
                    }
                });

                // Pagination
                document.getElementById('prev-page').addEventListener('click', () => {
                    if (currentPage > 0) {
                        currentPage--;
                        performCurrentSearch();
                    }
                });

                document.getElementById('next-page').addEventListener('click', () => {
                    if ((currentPage + 1) * resultsPerPage < totalResults) {
                        currentPage++;
                        performCurrentSearch();
                    }
                });

                // Check for URL parameters
                const urlParams = new URLSearchParams(window.location.search);
                const query = urlParams.get('q');
                const tag = urlParams.get('tag');
                const section = urlParams.get('section');

                if (query) {
                    document.getElementById('search-query').value = query;
                    performSearch();
                } else if (tag) {
                    document.getElementById('filter-tag').value = tag;
                    searchByTag();
                } else if (section) {
                    document.getElementById('filter-section').value = section;
                    searchBySection();
                }
            });

            async function loadSections() {
                try {
                    const response = await fetch('/api/sections');
                    const sections = await response.json();
                    
                    const select = document.getElementById('filter-section');
                    sections.forEach(section => {
                        const option = document.createElement('option');
                        option.value = section.id;
                        option.textContent = section.name;
                        select.appendChild(option);
                    });
                } catch (error) {
                    console.error('Error loading sections:', error);
                }
            }

            function performSearch() {
                const query = document.getElementById('search-query').value.trim();
                if (!query) {
                    alert('Por favor ingresa un término de búsqueda');
                    return;
                }
                
                currentQuery = query;
                currentSection = '';
                currentTag = '';
                currentPage = 0;
                
                document.getElementById('filter-section').value = '';
                document.getElementById('filter-tag').value = '';
                
                performCurrentSearch();
            }

            function searchBySection() {
                const section = document.getElementById('filter-section').value;
                if (!section) return;
                
                currentSection = section;
                currentQuery = '';
                currentTag = '';
                currentPage = 0;
                
                document.getElementById('search-query').value = '';
                document.getElementById('filter-tag').value = '';
                
                performCurrentSearch();
            }

            function searchByTag() {
                const tag = document.getElementById('filter-tag').value.trim();
                if (!tag) {
                    alert('Por favor ingresa un tag');
                    return;
                }
                
                currentTag = tag;
                currentQuery = '';
                currentSection = '';
                currentPage = 0;
                
                document.getElementById('search-query').value = '';
                document.getElementById('filter-section').value = '';
                
                performCurrentSearch();
            }

            async function performCurrentSearch() {
                const resultsDiv = document.getElementById('search-results');
                resultsDiv.innerHTML = '<p class="loading-text">Buscando...</p>';

                try {
                    let response;
                    let data;

                    if (currentQuery) {
                        const offset = currentPage * resultsPerPage;
                        response = await fetch(`/api/search?q=${encodeURIComponent(currentQuery)}&limit=${resultsPerPage}&offset=${offset}`);
                        data = await response.json();
                        totalResults = data.total;
                        displayResults(data.articles);
                    } else if (currentSection) {
                        const offset = currentPage * resultsPerPage;
                        response = await fetch(`/api/search/section/${currentSection}?limit=${resultsPerPage}&offset=${offset}`);
                        const articles = await response.json();
                        totalResults = articles.length;
                        displayResults(articles);
                    } else if (currentTag) {
                        const offset = currentPage * resultsPerPage;
                        response = await fetch(`/api/search/tag/${encodeURIComponent(currentTag)}?limit=${resultsPerPage}&offset=${offset}`);
                        const articles = await response.json();
                        totalResults = articles.length;
                        displayResults(articles);
                    }

                    updatePagination();
                } catch (error) {
                    console.error('Error searching:', error);
                    resultsDiv.innerHTML = '<p class="loading-text">Error al realizar la búsqueda. Por favor intenta de nuevo.</p>';
                }
            }

            function displayResults(articles) {
                const resultsDiv = document.getElementById('search-results');
                
                if (articles.length === 0) {
                    resultsDiv.innerHTML = `
                        <div class="no-results">
                            <h2>No se encontraron resultados</h2>
                            <p>Intenta con otros términos de búsqueda o filtros.</p>
                        </div>
                    `;
                    return;
                }

                resultsDiv.innerHTML = articles.map(article => `
                    <div class="result-card">
                        <h3><a href="/articles/${article.slug}">${article.title}</a></h3>
                        <p class="result-excerpt">${article.excerpt}</p>
                        <div class="result-meta">
                            <span>📅 ${new Date(article.published_at || article.created_at).toLocaleDateString('es-ES')}</span>
                        </div>
                        ${article.tags && article.tags.length > 0 ? `
                            <div class="result-tags">
                                ${article.tags.map(tag => `<span class="tag">${tag}</span>`).join('')}
                            </div>
                        ` : ''}
                    </div>
                `).join('');
            }

            function updatePagination() {
                const paginationDiv = document.getElementById('pagination');
                const prevButton = document.getElementById('prev-page');
                const nextButton = document.getElementById('next-page');
                const pageInfo = document.getElementById('page-info');

                if (totalResults <= resultsPerPage) {
                    paginationDiv.style.display = 'none';
                    return;
                }

                paginationDiv.style.display = 'flex';

                prevButton.disabled = currentPage === 0;
                nextButton.disabled = (currentPage + 1) * resultsPerPage >= totalResults;

                const start = currentPage * resultsPerPage + 1;
                const end = Math.min((currentPage + 1) * resultsPerPage, totalResults);
                pageInfo.textContent = `${start}-${end} de ${totalResults}`;
            }
        </script>
    </body>
</html>
