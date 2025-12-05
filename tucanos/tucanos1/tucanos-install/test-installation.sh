#!/bin/bash
# Test de l'installation de Tucanos

set -e

echo "=== Test de l'installation de Tucanos ==="

# Test FFI
echo "Test des bibliothÃ¨ques FFI..."
if [ -f "lib/libtucanos.so" ]; then
    echo "âœ“ BibliothÃ¨que FFI trouvÃ©e"
    ldd lib/libtucanos.so | head -5
else
    echo "âœ— BibliothÃ¨que FFI non trouvÃ©e"
fi

# Test Python
echo "Test des bindings Python..."
if command -v python3 &> /dev/null; then
    python3 -c "
try:
    import pytmesh
    print('âœ“ pytmesh importÃ© avec succÃ¨s')
except ImportError as e:
    print(f'âœ— Erreur import pytmesh: {e}')

try:
    import pytucanos
    print('âœ“ pytucanos importÃ© avec succÃ¨s')
except ImportError as e:
    print(f'âœ— Erreur import pytucanos: {e}')
"
else
    echo "âœ— Python3 non disponible"
fi

echo "Test terminÃ©"
