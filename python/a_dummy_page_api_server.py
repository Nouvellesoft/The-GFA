def format_text(text):
    """
    Capitalize acronyms, handle capitalization after parentheses, and ensure proper capitalization
    for each segment split by slashes, while removing unnecessary spaces around slashes.

    :param text: The text to format.
    :return: Formatted text.
    """
    # Remove leading/trailing whitespaces and replace multiple spaces with a single space
    text = text.strip()
    text = re.sub(r'\s+', ' ', text)

    # Remove extra spaces before closing parenthesis and ensure proper spacing
    text = re.sub(r'\s*\)\s*', ') ', text)

    # Capitalize text after parentheses
    def capitalize_after_parentheses(match):
        return match.group(1) + match.group(2).capitalize()

    # Regex to find text after parentheses and capitalize it
    text = re.sub(r'(\(.*?\))\s*(\w)', capitalize_after_parentheses, text)

    # Capitalize first letter of each word unless it's an acronym
    def capitalize_acronyms(word):
        return word.upper() if word.upper() in acronyms else word.capitalize()

    # Split text by '/' and process each part separately
    parts = [part.strip() for part in text.split('/')]
    capitalized_parts = []

    for part in parts:
        # Capitalize each word or acronym
        words = part.split()
        capitalized_words = [capitalize_acronyms(word) for word in words]
        capitalized_parts.append(' '.join(capitalized_words))

    # Join the parts with '/' ensuring no extra spaces around slashes
    formatted_text = '/'.join(capitalized_parts)

    return formatted_text
