import 'package:ahpsico/data/repositories/user_repository.dart';
import 'package:ahpsico/models/user.dart';
import 'package:ahpsico/services/api/exceptions.dart';
import 'package:ahpsico/services/auth/auth_service.dart';
import 'package:ahpsico/ui/signup/signup_model.dart';
import 'package:ahpsico/utils/mask_formatters.dart';
import 'package:faker/faker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthService extends Mock implements AuthService {}

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  final mockAuthService = MockAuthService();
  final mockUserRepository = MockUserRepository();

  SignUpModel? signUpModel;

  final user = User(
    uid: faker.guid.guid(),
    name: faker.person.name(),
    phoneNumber: faker.phoneNumber.random.fromPattern([MaskFormatters.phoneMaskPattern]),
    isDoctor: false,
  );

  when(() => mockUserRepository.clear()).thenAnswer((_) async {});
  when(() => mockAuthService.signOut()).thenAnswer((_) async {});

  setUpAll(() {
    registerFallbackValue(user);
  });

  setUp(() {
    signUpModel = SignUpModel(mockUserRepository, mockAuthService);
  });

  tearDown(() {
    try {
      signUpModel!.dispose();
    } catch (_) {}
    signUpModel = null;
  });

  group("complete sign up", () {
    test("user already registered will emit event", () async {
      when(() => mockUserRepository.create(any())).thenAnswer(
        (_) async => throw const ApiUserAlreadyRegisteredException(),
      );
      await signUpModel!.completeSignUp();
      expect(
          signUpModel!.eventStream,
          emitsInOrder([
            SignUpEvent.showSnackbarMessage,
            SignUpEvent.navigateToLogin,
          ]));
      assert(signUpModel!.snackbarMessage == "Ops! Parece que você já possui uma conta. Tente fazer login novamente");
      assert(!signUpModel!.isLoadingSignUp);
    });

    test("connection error emits event", () async {
      when(() => mockUserRepository.create(any())).thenAnswer(
        (_) async => throw const ApiConnectionException(),
      );
      await signUpModel!.completeSignUp();
      expect(signUpModel!.eventStream, emitsInOrder([SignUpEvent.showSnackbarError]));
      assert(signUpModel!.snackbarMessage ==
          "Ocorreu um erro ao tentar se conectar ao servidor. Certifique-se de que seu dispositivo esteja conectado corretamente com a internet");
      assert(!signUpModel!.isLoadingSignUp);
    });

    test("doctor signing up emits event", () async {
      when(() => mockUserRepository.create(any())).thenAnswer(
        (_) async => user.copyWith(isDoctor: true),
      );
      await signUpModel!.completeSignUp();
      expect(
          signUpModel!.eventStream,
          emitsInOrder([
            SignUpEvent.showSnackbarMessage,
            SignUpEvent.navigateToDoctorHome,
          ]));
      assert(signUpModel!.snackbarMessage == "Cadastro bem sucedido! Bem vindo(a) ${user.name}!");
      assert(!signUpModel!.isLoadingSignUp);
    });

    test("patient signing up emits event", () async {
      when(() => mockUserRepository.create(any())).thenAnswer(
        (_) async => user.copyWith(isDoctor: false),
      );
      await signUpModel!.completeSignUp();
      expect(
          signUpModel!.eventStream,
          emitsInOrder([
            SignUpEvent.showSnackbarMessage,
            SignUpEvent.navigateToPatientHome,
          ]));
      assert(signUpModel!.snackbarMessage == "Cadastro bem sucedido! Bem vindo(a) ${user.name}!");
      assert(!signUpModel!.isLoadingSignUp);
    });
  });

  test("cancel sign up show snackbar and navigates to login", () async {
    await signUpModel!.cancelSignUp();
    expect(
        signUpModel!.eventStream,
        emitsInOrder([
          SignUpEvent.showSnackbarMessage,
          SignUpEvent.navigateToLogin,
        ]));
    assert(signUpModel!.snackbarMessage == "Cadastro cancelado :(");
  });

  test("update name", () {
    const name = "some name";
    assert(signUpModel!.name.isEmpty);
    signUpModel!.updateName(name);
    assert(signUpModel!.name == name);
  });

  test("open cancelation dialog emitts event", () {
    signUpModel!.openCancelationDialog();
    expect(
      signUpModel!.eventStream,
      emitsInOrder([SignUpEvent.openCancelationDialog]),
    );
  });

  group("open confirmation dialog", () {
    test("empty name emits snackbar error event", () {
      signUpModel!.openConfirmationDialog(isDoctor: true);
      expect(
        signUpModel!.eventStream,
        emitsInOrder([SignUpEvent.showSnackbarError]),
      );
      assert(signUpModel!.snackbarMessage == "Preencha o campo com o seu nome para continuar");
    });
    test("blank name emits snackbar error event", () {
      signUpModel!.updateName("   ");
      signUpModel!.openConfirmationDialog(isDoctor: true);
      expect(
        signUpModel!.eventStream,
        emitsInOrder([SignUpEvent.showSnackbarError]),
      );
      assert(signUpModel!.snackbarMessage == "Preencha o campo com o seu nome para continuar");
    });
    test("invalid name emits snackbar error event", () {
      signUpModel!.updateName(List.generate(160, (index) => index.toString()).join());
      signUpModel!.openConfirmationDialog(isDoctor: true);
      expect(
        signUpModel!.eventStream,
        emitsInOrder([SignUpEvent.showSnackbarError]),
      );
      assert(signUpModel!.snackbarMessage ==
          "O seu nome é muito grande, por favor informe um nome que tenha menos de 150 caracteres");
    });
    test("doctor with valid name updates isDoctor field and emits event", () {
      signUpModel!.updateName("some name");
      assert(!signUpModel!.isDoctor);
      signUpModel!.openConfirmationDialog(isDoctor: true);
      expect(
        signUpModel!.eventStream,
        emitsInOrder([SignUpEvent.openConfirmationDialog]),
      );
      assert(signUpModel!.isDoctor);
      assert(signUpModel!.snackbarMessage == null);
    });
    test("patient with valid name updates isDoctor field and emits event", () {
      signUpModel!.updateName("some name");
      assert(!signUpModel!.isDoctor);
      signUpModel!.openConfirmationDialog(isDoctor: false);
      expect(
        signUpModel!.eventStream,
        emitsInOrder([SignUpEvent.openConfirmationDialog]),
      );
      assert(!signUpModel!.isDoctor);
      assert(signUpModel!.snackbarMessage == null);
    });
  });
}
