resource "azurerm_servicebus_namespace" "main" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  capacity            = var.capacity
  tags                = var.tags
}

resource "azurerm_servicebus_namespace_authorization_rule" "main" {
  count = length(local.authorization_rules)

  name                = local.authorization_rules[count.index].name
  namespace_id        = azurerm_servicebus_namespace.main.id

  listen = contains(local.authorization_rules[count.index].rights, "listen") ? true : false
  send   = contains(local.authorization_rules[count.index].rights, "send") ? true : false
  manage = contains(local.authorization_rules[count.index].rights, "manage") ? true : false
}

resource "azurerm_servicebus_topic" "main" {
  count = length(local.topics)

  name                = local.topics[count.index].name
  namespace_id        = azurerm_servicebus_namespace.main.id

  status                       = local.topics[count.index].status
  auto_delete_on_idle          = local.topics[count.index].auto_delete_on_idle
  default_message_ttl          = local.topics[count.index].default_message_ttl
  enable_batched_operations    = local.topics[count.index].enable_batched_operations
  enable_express               = local.topics[count.index].enable_express
  enable_partitioning          = local.topics[count.index].enable_partitioning
  max_size_in_megabytes        = local.topics[count.index].max_size
  requires_duplicate_detection = local.topics[count.index].enable_duplicate_detection
  support_ordering             = local.topics[count.index].enable_ordering

  duplicate_detection_history_time_window = local.topics[count.index].duplicate_detection_history_time_window
}

resource "azurerm_servicebus_topic_authorization_rule" "main" {
  count = length(local.topic_authorization_rules)

  name                = local.topic_authorization_rules[count.index].name
  topic_id            = azurerm_servicebus_topic.main[count.index].id

  listen = contains(local.topic_authorization_rules[count.index].rights, "listen") ? true : false
  send   = contains(local.topic_authorization_rules[count.index].rights, "send") ? true : false
  manage = contains(local.topic_authorization_rules[count.index].rights, "manage") ? true : false

  depends_on = [azurerm_servicebus_topic.main]
}

resource "azurerm_servicebus_subscription" "main" {
  count = length(local.topic_subscriptions)

  name                = local.topic_subscriptions[count.index].name
  topic_id            = azurerm_servicebus_topic.main[count.index].id

  max_delivery_count        = local.topic_subscriptions[count.index].max_delivery_count
  auto_delete_on_idle       = local.topic_subscriptions[count.index].auto_delete_on_idle
  default_message_ttl       = local.topic_subscriptions[count.index].default_message_ttl
  lock_duration             = local.topic_subscriptions[count.index].lock_duration
  enable_batched_operations = local.topic_subscriptions[count.index].enable_batched_operations
  requires_session          = local.topic_subscriptions[count.index].enable_session
  forward_to                = local.topic_subscriptions[count.index].forward_to

  dead_lettering_on_message_expiration = local.topic_subscriptions[count.index].enable_dead_lettering_on_message_expiration

  depends_on = [azurerm_servicebus_topic.main]
}

resource "azurerm_servicebus_subscription_rule" "main" {
  count = length(local.topic_subscription_rules)

  name                = local.topic_subscription_rules[count.index].name
  subscription_id     = local.topic_subscriptions[count.index].id
  filter_type         = local.topic_subscription_rules[count.index].sql_filter != "" ? "SqlFilter" : null
  sql_filter          = local.topic_subscription_rules[count.index].sql_filter
  action              = local.topic_subscription_rules[count.index].action

  depends_on = [azurerm_servicebus_subscription.main]
}

resource "azurerm_servicebus_queue" "main" {
  count = length(local.queues)

  name                = local.queues[count.index].name
  namespace_id        = azurerm_servicebus_namespace.main.id

  auto_delete_on_idle                  = local.queues[count.index].auto_delete_on_idle
  default_message_ttl                  = local.queues[count.index].default_message_ttl
  enable_express                       = local.queues[count.index].enable_express
  enable_partitioning                  = local.queues[count.index].enable_partitioning
  lock_duration                        = local.queues[count.index].lock_duration
  max_size_in_megabytes                = local.queues[count.index].max_size
  requires_duplicate_detection         = local.queues[count.index].enable_duplicate_detection
  requires_session                     = local.queues[count.index].enable_session
  dead_lettering_on_message_expiration = local.queues[count.index].enable_dead_lettering_on_message_expiration
  max_delivery_count                   = local.queues[count.index].max_delivery_count

  duplicate_detection_history_time_window = local.queues[count.index].duplicate_detection_history_time_window
}

resource "azurerm_servicebus_queue_authorization_rule" "main" {
  count = length(local.queue_authorization_rules)

  name                = local.queue_authorization_rules[count.index].name
  queue_id            = local.queue_authorization_rules[count.index].queue_id

  listen = contains(local.queue_authorization_rules[count.index].rights, "listen") ? true : false
  send   = contains(local.queue_authorization_rules[count.index].rights, "send") ? true : false
  manage = contains(local.queue_authorization_rules[count.index].rights, "manage") ? true : false

  depends_on = [azurerm_servicebus_queue.main]
}