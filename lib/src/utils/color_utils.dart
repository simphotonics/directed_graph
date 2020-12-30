/// Ansi color modifier: Reset to default.
const String RESET = '\u001B[0m';

/// Ansi color modifier.
const String BLUE = '\u001B[1;94m';

const String MAGENTA = '\u001B[1;95m';

/// Ansi color modifier.
const String CYAN = '\u001B[36m';

/// Ansi color modifier.
const String GREEN = '\u001B[32m';

/// Ansi color modifier.
const String RED = '\u001B[31m';

/// Ansi color modifier.
const String YELLOW = '\u001B[33m';

String magenta(String input) => '$MAGENTA$input$RESET';
String green(String input) => '$GREEN$input$RESET';
String blue(String input) => '$BLUE$input$RESET';
