resource "azurerm_monitor_autoscale_setting" "autoscale" {
    name                = azurerm_orchestrated_virtual_machine_scale_set.vmss_infra.name
    resource_group_name         = azurerm_resource_group.rg.name
    location                    = azurerm_resource_group.rg.name
    target_resource_id  = azurerm_orchestrated_virtual_machine_scale_set.vmss_infra.id
    enabled = true
    profile {
        name = "AutoScaleProfile"

        capacity {
        default = var.default_capacity
        minimum = var.min_capacity
        maximum = var.max_capacity
        }

        rule {
        metric_trigger {
            metric_name        = "Percentage CPU"
            metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
            time_grain         = "PT1M"
            statistic          = "Average"
            time_window        = "PT5M"
            time_aggregation   = "Average"
            operator           = "GreaterThan"
            threshold          = var.cpu_threshold
        }

        scale_action {
            direction = "Increase"
            type      = "ChangeCount"
            value     = var.scale_out_value
            cooldown  = "PT5M"
        }
        }

        rule {
        metric_trigger {
            metric_name        = "Percentage CPU"
            metric_resource_id = azurerm_linux_virtual_machine_scale_set.vmss.id
            time_grain         = "PT1M"
            statistic          = "Average"
            time_window        = "PT5M"
            time_aggregation   = "Average"
            operator           = "LessThan"
            threshold          = var.cpu_threshold
        }

        scale_action {
            direction = "Decrease"
            type      = "ChangeCount"
            value     = var.scale_in_value
            cooldown  = "PT5M"
        }
        }
    }
}