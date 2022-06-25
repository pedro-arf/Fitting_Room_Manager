import 'package:fr_control/services/auth/auth_exceptions.dart';
import 'package:fr_control/services/auth/auth_provider.dart';
import 'package:fr_control/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group('Mock Authentication', () {
    final provider = MockAuthProvider();
    test('Should not be initialized to begin with', () {
      expect(provider.isInitialized, false);
    });
    test('Cannot log out if not initialized', () {
      expect(
        provider.logOut(), // execute the logout function
        throwsA(const TypeMatcher<
            NotInitializedException>()), //test the result of that function against a type matcher
      );
    });
    test(
      'Should be able to be initialized',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
    );
    test(
      'User should be null after initialization',
      () {
        expect(provider.currentUser, null);
      },
    );
    test(
      'Should be able to initialize in less than 2 secoonds',
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    ); // se a função initialize não for inicializada em menos de dois segundos o teste falha (timeout cria um timer)
    test(
      'Create user should delegate to log in function',
      () async {
        final badEmailUser = provider.createUser(
          email: 'foo@bar.com',
          password: 'anypassword',
        );
        expect(badEmailUser,
            throwsA(const TypeMatcher<UserNotFoundAuthException>()));

        final badPasswordUser = provider.createUser(
          email: 'someone@bar.com',
          password: 'foobar',
        );
        expect(badPasswordUser,
            throwsA(const TypeMatcher<WrongPasswordAuthException>()));

        final user = await provider.createUser(
          email: 'foo',
          password: 'bar',
        );
        expect(provider.currentUser, user);
        expect(user.isEmailVerified, false);
      },
    );
    test(
      'A logged in user should be able to get verified',
      () {
        provider.sendEmailVerification();
        final user = provider.currentUser;
        expect(user, isNotNull);
        expect(user!.isEmailVerified, true);
      },
    );

    test(
      'Should be able to og out and log in again',
      () async {
        await provider.logOut();
        await provider.logIn(
          email: 'email',
          password: 'password',
        );
        final user = provider.currentUser;
        expect(user, isNotNull);
      },
    );
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser?
      _user; // inicializa variável a null se esta não estiver já inicializada
  var _isInitialized =
      false; // o underscore faz com que esta variável seja privada, ou seja só pode ser lida neste ambiente de teste e não no resto do programa
  bool get isInitialized => _isInitialized;
  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    if (!isInitialized) {
      throw NotInitializedException();
    } // checks if user is initialized
    await Future.delayed(
        const Duration(seconds: 1)); // delay to fake an API call
    return logIn(
      email: email,
      password: password,
    ); // returns log in
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    if (!isInitialized) {
      throw NotInitializedException();
    }
    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'foobar') throw WrongPasswordAuthException();
    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) {
      throw NotInitializedException();
    } // checks if user is initialized
    if (_user == null) {
      throw UserNotFoundAuthException();
    } // checks if user is logged in
    await Future.delayed(const Duration(seconds: 1)); // fake calls API
    _user = null; // logs user out
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) {
      throw NotInitializedException();
    } // checks if user is initialized
    final user = _user;
    if (user == null) {
      throw UserNotFoundAuthException();
    } // checks if user is logged in
    const newUser = AuthUser(isEmailVerified: true); // validates email
    _user = newUser;
  }
}
