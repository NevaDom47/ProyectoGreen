
with open(r'c:\Users\Referencia\Documents\Programas Antigravity\App Mercadito\app_mercadito\lib\screens\negotiations_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()
    open_braces = content.count('{')
    close_braces = content.count('}')
    print(f'Open: {open_braces}')
    print(f'Close: {close_braces}')
