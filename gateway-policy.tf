# ==============================================================================
# LISTS: AD Blocking domain list
#
# Remote source:
#   - https://firebog.net/
#   - https://adaway.org/hosts.txt
# Local file:
#   - ./cloudflare/lists/pihole_domain_list.txt
#   - the file can be updated periodically via Github Actions (see README)
# ==============================================================================
locals {
  # The full path of the list holding the domain list
  pihole_domain_list_file = "${path.module}/cloudflare/lists/pihole_domain_list.txt"

  # Parse the file and create a list, one item per line
  pihole_domain_list = split("\n", file(local.pihole_domain_list_file))

  # Remove empty lines
  # pihole_domain_list_clean = [for x in local.pihole_domain_list : x if x != ""]
  pihole_domain_list_clean = [for x in local.pihole_domain_list : x if x != "" && !startswith(x, "#")]


  # Use chunklist to split a list into fixed-size chunks
  # It returns a list of lists
  pihole_aggregated_lists = chunklist(local.pihole_domain_list_clean, 1000)

  # Get the number of lists (chunks) created
  pihole_list_count = length(local.pihole_aggregated_lists)
}


resource "cloudflare_teams_list" "pihole_domain_lists" {
  account_id = local.cloudflare_account_id

  for_each = {
    for i in range(0, local.pihole_list_count) :
    i => element(local.pihole_aggregated_lists, i)
  }

  name  = "pihole_domain_list_${each.key}"
  type  = "DOMAIN"
  items = each.value
}
