locals {
  # toset(list) -> set
  # - Converts a list into a set, removing duplicate values.
  # Structure: toset(<list>)
  unique_paths = toset(var.paths_to_validate)

  # fileexists(path) -> bool
  # - Returns true if a file exists at the given filesystem path.
  # Structure: fileexists(<string>)
  #
  # dirname(path) -> string
  # - Extracts the directory portion of a filesystem path.
  # Structure: dirname(<string>)
  #
  # basename(path) -> string
  # - Extracts the filename portion of a filesystem path.
  # Structure: basename(<string>)
  #
  # This builds a map where each path is validated and decomposed.
  validations = {
    for p in local.unique_paths : p => {
      exists = fileexists(p)
      dir    = dirname(p)
      file   = basename(p)
    }
  }

  # distinct(list) -> list
  # - Removes duplicate elements while preserving order.
  # Structure: distinct(<list>)
  #
  # sort(list) -> list
  # - Sorts a list of strings lexicographically.
  # Structure: sort(<list>)
  #
  # Extracts and normalizes all referenced directories.
  directories = sort(distinct([
    for _, v in local.validations : v.dir
  ]))

  # compact(list) -> list
  # - Removes null or empty string elements from a list.
  # Structure: compact(<list>)
  #
  # Collects only missing file paths.
  missing_paths = compact([
    for p, v in local.validations : (v.exists ? null : p)
  ])

  # length(collection|string) -> number
  # - Returns the number of elements in a collection or characters in a string.
  # Structure: length(<value>)
  #
  # Aggregated validation status.
  status_summary = {
    total_paths   = length(local.validations)
    missing_count = length(local.missing_paths)
    ok            = length(local.missing_paths) == 0
  }

  user_locations = [
    "East US",
    "West Europe",
    "East US",  # Duplicate entry to demonstrate set conversion
  ]
  default_locations = ["Central US"]

  # concat(list1, list2, ...) -> list
  # - Combines multiple lists into a single list in order.
  # Structure: concat(<list>, <list>, ...)
  #
  # toset(list) -> set
  # - Converts a list into a set, removing duplicate values.
  # Structure: toset(<list>)
  #
  # Here, we merge default and user locations, then remove duplicates.
  unique_locations = toset(concat(
    local.default_locations,
    local.user_locations
  ))

  monthly_costs = [-50, 100, 200, -25, 75]
  # abs(number) -> number
  # - Returns the absolute value of a number.
  # Structure: abs(<number>)
  #
  # Here, we normalize costs so all values are non-negative.
  positive_costs = [for cost in local.monthly_costs : abs(cost)]
  # The `...` (splat expansion) operator:
  # - Expands a list into individual arguments.
  # - Required because `max()` does NOT accept a list directly.
  max_cost = max(local.positive_costs...)

  # file(path) -> string
  # - Reads the contents of a file into a string.
  # Structure: file(<path>)
  #
  # sensitive(value) -> any
  # - Marks a value as sensitive to reduce accidental exposure.
  # Structure: sensitive(<value>)
  #
  # Here, we load a JSON config file and mark its contents as sensitive.
  config_file_content = sensitive(file("${path.module}/config/settings.json"))
}
