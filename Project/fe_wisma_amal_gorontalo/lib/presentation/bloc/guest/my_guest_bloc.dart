import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/domain/entity/guest/guest_entity.dart';
import 'package:frontend/domain/usecase/guest/create_guest_usecase.dart';
import 'package:frontend/domain/usecase/guest/delete_guest_usecase.dart';
import 'package:frontend/domain/usecase/guest/extend_my_guest_usecase.dart'; 
import 'package:frontend/domain/usecase/guest/get_my_guests_usecase.dart';
import 'package:frontend/domain/usecase/guest/pay_guest_bill_usecase.dart';
import 'package:frontend/domain/usecase/guest/checkout_my_guest_usecase.dart';

// ─── Events ───────────────────────────────────────────────────────────────────

abstract class MyGuestEvent {}

class FetchMyGuests extends MyGuestEvent {}

class CreateMyGuest extends MyGuestEvent {
  final List<Map<String, dynamic>> guests; // <-- REVISION: Using guest array
  final List<Uint8List> identityImages;
  final List<String> identityImageNames;
  final String checkInAt;
  final String checkOutAt;

  CreateMyGuest({
    required this.guests,
    required this.identityImages,
    required this.identityImageNames,
    required this.checkInAt,
    required this.checkOutAt,
  });
}

class DeleteMyGuest extends MyGuestEvent {
  final int id;
  DeleteMyGuest(this.id);
}

class PayGuestBillManual extends MyGuestEvent {
  final int guestId;
  final Uint8List proofBytes;
  final String proofName;
  PayGuestBillManual({
    required this.guestId,
    required this.proofBytes,
    required this.proofName,
  });
}

class PayGuestBillCash extends MyGuestEvent { // <-- REVISION: Cash payment event
  final int guestId;
  PayGuestBillCash(this.guestId);
}

class PayGuestBillMidtrans extends MyGuestEvent {
  final int guestId;
  PayGuestBillMidtrans(this.guestId);
}

class CheckoutMyGuest extends MyGuestEvent {
  final int id;
  CheckoutMyGuest(this.id);
}

class ExtendMyGuest extends MyGuestEvent {
  final int id;
  final String newCheckOutAt;

  ExtendMyGuest({required this.id, required this.newCheckOutAt});
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class MyGuestState {}

class MyGuestInitial extends MyGuestState {}

class MyGuestLoading extends MyGuestState {}

class MyGuestLoaded extends MyGuestState {
  final List<MyGuestItem> guests;
  MyGuestLoaded(this.guests);
}

class MyGuestError extends MyGuestState {
  final String message;
  MyGuestError(this.message);
}

class MyGuestActionSuccess extends MyGuestState {
  final String message;
  MyGuestActionSuccess(this.message);
}

class MyGuestActionError extends MyGuestState {
  final String message;
  MyGuestActionError(this.message);
}

class MyGuestMidtransInitiated extends MyGuestState {
  final String snapToken;
  final String message;
  MyGuestMidtransInitiated({required this.snapToken, required this.message});
}

// ─── BLoC ─────────────────────────────────────────────────────────────────────

class MyGuestBloc extends Bloc<MyGuestEvent, MyGuestState> {
  final GetMyGuestsUseCase getMyGuestsUseCase;
  final CreateGuestUseCase createGuestUseCase;
  final DeleteGuestUseCase deleteGuestUseCase;
  final PayGuestBillUseCase payGuestBillUseCase;
  final CheckoutMyGuestUseCase checkoutMyGuestUseCase;
  final ExtendMyGuestUseCase extendMyGuestUseCase; 

  MyGuestBloc({
    required this.getMyGuestsUseCase,
    required this.createGuestUseCase,
    required this.deleteGuestUseCase,
    required this.payGuestBillUseCase,
    required this.checkoutMyGuestUseCase,
    required this.extendMyGuestUseCase,
  }) : super(MyGuestInitial()) {
    on<FetchMyGuests>(_onFetch);
    on<CreateMyGuest>(_onCreate);
    on<DeleteMyGuest>(_onDelete);
    on<PayGuestBillManual>(_onPayManual);
    on<PayGuestBillCash>(_onPayCash); // <-- REVISION: Register the cash payment event
    on<PayGuestBillMidtrans>(_onPayMidtrans);
    on<CheckoutMyGuest>(_onCheckout);
    on<ExtendMyGuest>(_onExtend);
  }

  Future<void> _onExtend(ExtendMyGuest event, Emitter<MyGuestState> emit) async {
    try {
      await extendMyGuestUseCase(event.id, event.newCheckOutAt);
      emit(MyGuestActionSuccess('Guest stay period successfully extended.'));
      final guests = await getMyGuestsUseCase();
      emit(MyGuestLoaded(guests));
    } catch (e) {
      emit(MyGuestActionError(e.toString()));
    }
  }

  Future<void> _onCheckout(CheckoutMyGuest event, Emitter<MyGuestState> emit) async {
    try {
      await checkoutMyGuestUseCase(event.id);
      emit(MyGuestActionSuccess('Guest successfully checked out.'));
      final guests = await getMyGuestsUseCase();
      emit(MyGuestLoaded(guests));
    } catch (e) {
      emit(MyGuestActionError(e.toString()));
    }
  }

  Future<void> _onFetch(FetchMyGuests event, Emitter<MyGuestState> emit) async {
    emit(MyGuestLoading());
    try {
      final guests = await getMyGuestsUseCase();
      emit(MyGuestLoaded(guests));
    } catch (e) {
      emit(MyGuestError(e.toString()));
    }
  }

  Future<void> _onCreate(
      CreateMyGuest event, Emitter<MyGuestState> emit) async {
    try {
      await createGuestUseCase(
        guests: event.guests, // <-- REVISION: Pass array to UseCase
        identityImages: event.identityImages,
        identityImageNames: event.identityImageNames,
        checkInAt: event.checkInAt,
        checkOutAt: event.checkOutAt,
      );
      emit(MyGuestActionSuccess('Guest data successfully added.'));
      
      final guests = await getMyGuestsUseCase();
      emit(MyGuestLoaded(guests));
    } catch (e) {
      emit(MyGuestActionError(e.toString()));
    }
  }

  Future<void> _onDelete(
      DeleteMyGuest event, Emitter<MyGuestState> emit) async {
    try {
      await deleteGuestUseCase(event.id);
      emit(MyGuestActionSuccess('Guest data successfully deleted.'));
      final guests = await getMyGuestsUseCase();
      emit(MyGuestLoaded(guests));
    } catch (e) {
      emit(MyGuestActionError(e.toString()));
    }
  }

  Future<void> _onPayManual(
      PayGuestBillManual event, Emitter<MyGuestState> emit) async {
    try {
      await payGuestBillUseCase(
        guestId: event.guestId,
        paymentMethod: 'manual',
        proofBytes: event.proofBytes,
        proofName: event.proofName,
      );
      emit(MyGuestActionSuccess('Payment proof successfully sent. Waiting for admin verification.'));
      final guests = await getMyGuestsUseCase();
      emit(MyGuestLoaded(guests));
    } catch (e) {
      emit(MyGuestActionError(e.toString()));
    }
  }

  Future<void> _onPayCash( // <-- REVISION: Dedicated cash payment method
      PayGuestBillCash event, Emitter<MyGuestState> emit) async {
    try {
      await payGuestBillUseCase(
        guestId: event.guestId,
        paymentMethod: 'cash',
      );
      emit(MyGuestActionSuccess('Cash payment submitted. Please hand the money to the caretaker.'));
      final guests = await getMyGuestsUseCase();
      emit(MyGuestLoaded(guests));
    } catch (e) {
      emit(MyGuestActionError(e.toString()));
    }
  }

  Future<void> _onPayMidtrans(
      PayGuestBillMidtrans event, Emitter<MyGuestState> emit) async {
    try {
      final bill = await payGuestBillUseCase(
        guestId: event.guestId,
        paymentMethod: 'midtrans',
      );
      if (bill.snapToken != null) {
        emit(MyGuestMidtransInitiated(
          snapToken: bill.snapToken!,
          message: 'Payment page is ready to open.',
        ));
      } else {
        emit(MyGuestActionError('Failed to get the Midtrans payment token.'));
      }
      final guests = await getMyGuestsUseCase();
      emit(MyGuestLoaded(guests));
    } catch (e) {
      emit(MyGuestActionError(e.toString()));
    }
  }
}