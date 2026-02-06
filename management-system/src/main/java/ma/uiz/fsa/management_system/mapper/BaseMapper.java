package ma.uiz.fsa.management_system.mapper;

public interface BaseMapper<E, REQ, RES> {
    E toEntity(REQ requestDto);
    RES toResponseDto(E entity);
    void updateEntityFromDto(REQ requestDto, E entity);
}
