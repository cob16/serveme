json.reservation do
  json.status reservation.status
  json.partial! 'api/reservations/reservation', reservation: @reservation
  json.status_messages reservation.reservation_statuses.order(:created_at).pluck(:status)
end