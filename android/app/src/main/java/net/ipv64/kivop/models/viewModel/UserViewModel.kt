package net.ipv64.kivop.models.viewModel

import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.launch
import net.ipv64.kivop.dtos.AuthServiceDTOs.UserProfileDTO
import net.ipv64.kivop.dtos.AuthServiceDTOs.UserProfileUpdateDTO
import net.ipv64.kivop.services.api.getUserProfile
import net.ipv64.kivop.services.api.patchUserProfile
import net.ipv64.kivop.services.encodeImageToBase64

class UserViewModel : ViewModel() {
  private var user by mutableStateOf<UserProfileDTO?>(null)
    private set

  fun fetchUser() {
    viewModelScope.launch {
      val response = getUserProfile() // Call the API service to get user profile
      response?.let { user = it } // Set the user profile in ViewModel state
    }
  }

  fun getProfile(): UserProfileDTO? {
    return this.user
  }

  fun updateUser(email: String? = null, name: String? = null, profileImage: String? = null) {
    user?.let {
      val updatedUser =
          it.copy(
              email = email ?: it.email,
              name = if (name?.isNotEmpty() == true) name else it.name,
              profileImage = profileImage ?: it.profileImage)
      if (updatedUser != it) {

        viewModelScope.launch {
          val response =
              patchUserProfile(
                  UserProfileUpdateDTO(
                    name = if (name.isNullOrEmpty()) null else name,
                    profileImage
                  ))
          if (response?.isSuccessful == true) {
            user = updatedUser
          }
        }
      }
    }
  }

  init {}
}
