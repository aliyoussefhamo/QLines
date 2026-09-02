import { Logger } from '@nestjs/common';
import {
  OnGatewayConnection,
  WebSocketGateway,
  WebSocketServer,
} from '@nestjs/websockets';
import type { Server, Socket } from 'socket.io';
import { TokenService } from '../auth/token.service';
import { UserRole } from '../users/models/user-role';

export type ReservationChangedEvent = {
  reservationId: string;
  status: string;
};

@WebSocketGateway({ cors: { origin: true } })
export class ReservationEventsGateway implements OnGatewayConnection {
  private readonly logger = new Logger(ReservationEventsGateway.name);

  @WebSocketServer()
  private readonly server: Server;

  constructor(private readonly tokenService: TokenService) {}

  handleConnection(client: Socket): void {
    const auth = client.handshake.auth as Record<string, unknown>;
    const token = auth.token;
    if (typeof token !== 'string') {
      client.disconnect(true);
      return;
    }
    try {
      const user = this.tokenService.verify(token);
      void client.join(`user:${user.sub}`);
      if (
        (user.role === UserRole.Staff || user.role === UserRole.Admin) &&
        user.employeeBranchId
      ) {
        void client.join(`branch:${user.employeeBranchId}`);
      }
    } catch {
      this.logger.warn(`Rejected unauthorized socket ${client.id}`);
      client.disconnect(true);
    }
  }

  reservationChanged(
    userId: string,
    branchId: string,
    event: ReservationChangedEvent,
  ): void {
    this.server.to(`user:${userId}`).emit('reservation.changed', event);
    this.server.to(`branch:${branchId}`).emit('reservation.changed', event);
  }
}
