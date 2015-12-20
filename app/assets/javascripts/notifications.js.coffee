class Notifications
  # https://gorails.com/episodes/in-app-navbar-notifications?autoplay=1
  constructor: ->
    @notifications = $("[data-behavior = 'notifications']")
    @setup() if @notifications.length > 0

  setup: ->
    $("[data-behavior='notifications-link']").on "click", @handleClick
    $.ajax(
      url: '/notifications.json'
      dataType: "JSON"
      method: "GET"
      success: @handleSuccess
    )

  handleClick: (e) =>
    $.ajax(
      url:"/notifications/mark_as_read"
      dataType: "JSON"
      method: "POST"
      success: ->
        $("[data-behavior='unread-count']").text(0)
    )
  handleSuccess: (data) =>
    items = $.map data, (notification) ->
      "<a class='dropdown-item' href='#'>#{notification.action} </a>"

    $("[data-behavior='unread-count']").text(items.length)
    $("[data-behavior='notification-items']").html(items)

jQuery ->
  new Notifications

# #{notification.url}
