import platey/plates

const style = """
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@picocss/pico@1/css/pico.min.css">
    """
plates:
  plate "my component":
    style & """
    <button>Here is my button</button>
    """

  plate "my other component":
    style & """
    <button class="secondary">Secondary button</button>
    """
