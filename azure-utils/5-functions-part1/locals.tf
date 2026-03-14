locals {
  # lower(string) -> string
  # - Converts all characters in a string to lowercase.
  # replace(string, substring, replacement) -> string
  # - Returns a new string where every occurrence of `substring` is replaced by `replacement`.
  # Here, we normalize `var.project_name` to a lowercase, dash-separated identifier (e.g., "My Project" -> "my-project").
  formatted_name = lower(replace(var.project_name, " ", "-"))

  # merge(map1, map2, ...) -> map
  # - Combines multiple maps into one. If the same key exists in multiple maps, the later map wins.
  # Here, `var.environment_tags` overrides keys in `var.default_tags` when they overlap.
  merged_tags = merge(
    var.default_tags,
    var.environment_tags,
    {
      date = local.tag_date
    }
  )

  # lower(string) -> string
  # - Converts a string to lowercase.
  # regexall(pattern, string) -> list(string)
  # - Returns a list of all substrings that match the regex `pattern`.
  # join(separator, list) -> string
  # - Concatenates list elements into a single string, separated by `separator`.
  # substr(string, offset, length) -> string
  # - Extracts a substring from `string`, starting at `offset`, with maximum `length` characters.
  #
  # Here, we build a Storage Account name that:
  # - is lowercase,
  # - contains only [a-z0-9],
  # - and is truncated to Azure's max length (23 chars).
  storage_formatted = substr(join("", regexall("[a-z0-9]", lower(var.storage_account_name))), 0, 23)

  # split(separator, string) -> list(string)
  # - Splits a string into a list using `separator`.
  # trimspace(string) -> string
  # - Removes leading/trailing whitespace from a string.
  #
  # Here, we convert a comma-separated string like "22, 80,443" into ["22","80","443"].
  formatted_ports = [for p in split(",", var.allowed_ports) : trimspace(p)]

  # for-expressions: [for <index>, <value> in <collection> : <expr>]
  # - Produces a new list by iterating over a collection.
  # Here, we generate NSG rule objects from `local.formatted_ports`,
  # and use the index `i` to produce deterministic priorities (100 + i).
  nsg_rules = [for i, port in local.formatted_ports : {
    name        = "port-${port}"
    port        = port
    priority    = 100 + i
    description = "Allow traffic on port ${port}"
  }]

  # lookup(map, key, default) -> any
  # - Reads `map[key]` if it exists; otherwise returns `default`.
  # Here, we pick the VM size based on environment, defaulting to "Standard_B2s".
  vm_size = lookup(var.vm_sizes, var.environment, "Standard_B2s")

  # timestamp() -> string
  # - Returns the current time in RFC 3339 format.
  # Structure: timestamp()
  current_time = timestamp()
  # formatdate(format, time) -> string
  # - Formats a timestamp using the given pattern.
  # Structure: formatdate(<format>, <timestamp>)
  #
  # Here, we derive a compact resource name and a YYYY-MM-DD tag value.
  resource_name = formatdate("YYYYMMDD-HHMMSS", local.current_time)
  tag_date      = formatdate("YYYY-MM-DD", local.current_time)
}
